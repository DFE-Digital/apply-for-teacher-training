require 'rails_helper'

RSpec.describe ProviderInterface::CandidatePoolFilter do
  include Rails.application.routes.url_helpers

  describe '#filters' do
    it 'returns the filters' do
      current_provider_user = create(:provider_user)
      filter = described_class.new(filter_params: {}, current_provider_user:)

      expect(filter.filters).to eq([
        {
          type: :location_search,
          heading: 'Town, city or postcode:',
          name: 'location_search',
          original_location: nil,
          title: 'Candidate location preferences',
          path_to_location_suggestions: provider_interface_location_suggestions_path,
        },
        {
          type: :checkbox_filter,
          heading: 'Subjects previously applied to',
          name: 'subject',
          options: [],
          hide_tags: true,
          title: 'Candidate course preferences',
        },
        {
          type: :checkboxes,
          heading: 'Study type',
          name: 'study_mode',
          options: [
            {
              value: 'full_time',
              label: 'Full time',
              checked: nil,
            },
            {
              value: 'part_time',
              label: 'Part time',
              checked: nil,
            },
          ],
        },
        {
          type: :checkboxes,
          heading: 'Course type',
          name: 'course_type',
          options: [
            {
              value: 'TDA',
              label: 'Undergraduate',
              checked: nil,
            },
            {
              value: 'HE,HES,SD,SS,SC,SSC,TA',
              label: 'Postgraduate',
              checked: nil,
            },
          ],
        },
        {
          type: :checkboxes,
          heading: '<h3 class="govuk-heading-m govuk-!-margin-bottom-0">Candidate’s visa requirements</h3>',
          name: 'visa_sponsorship',
          options: [
            {
              value: 'required',
              label: 'Needs a visa',
              checked: nil,
            },
            {
              value: 'not required',
              label: 'Does not need a visa',
              checked: nil,
            },
          ],
        },
      ])
    end
  end

  describe 'set_filters' do
    it 'saves the filters on the provider user' do
      filter_params = {
        'original_location' => 'Manchester',
        'visa_sponsorship' => ['required'],
      }
      current_provider_user = create(:provider_user)

      expect { described_class.new(filter_params:, current_provider_user:) }.to(
        change { current_provider_user.find_a_candidate_filters }.from({}).to(filter_params),
      )
    end

    context 'when clearing the filters' do
      it 'removes the filters from DB' do
        filter_params = { remove: 'true' }
        current_provider_user = create(:provider_user, find_a_candidate_filters: { 'original_location' => 'Manchester' })

        expect { described_class.new(filter_params:, current_provider_user:) }.to(
          change { current_provider_user.find_a_candidate_filters }.from({ 'original_location' => 'Manchester' }).to({}),
        )
      end
    end

    context 'when filters already exist in DB' do
      it 'stores updated filters' do
        filter_params = {
          'original_location' => 'Manchester',
        }
        current_provider_user = create(
          :provider_user,
          find_a_candidate_filters: { 'visa_sponsorship' => ['required'] },
        )

        expect { described_class.new(filter_params:, current_provider_user:) }.to(
          change { current_provider_user.find_a_candidate_filters }
          .from({ 'visa_sponsorship' => ['required'] })
          .to(filter_params),
        )
      end
    end

    context 'when current_provider_user is nil' do
      it 'stores updated filters' do
        filter = described_class.new(filter_params: {}, current_provider_user: nil)

        expect(filter.filters).to eq([
          {
            type: :location_search,
            heading: 'Town, city or postcode:',
            name: 'location_search',
            original_location: nil,
            title: 'Candidate location preferences',
            path_to_location_suggestions: provider_interface_location_suggestions_path,
          },
          {
            type: :checkbox_filter,
            heading: 'Subjects previously applied to',
            name: 'subject',
            options: [],
            hide_tags: true,
            title: 'Candidate course preferences',
          },
          {
            type: :checkboxes,
            heading: 'Study type',
            name: 'study_mode',
            options: [
              {
                value: 'full_time',
                label: 'Full time',
                checked: nil,
              },
              {
                value: 'part_time',
                label: 'Part time',
                checked: nil,
              },
            ],
          },
          {
            type: :checkboxes,
            heading: 'Course type',
            name: 'course_type',
            options: [
              {
                value: 'TDA',
                label: 'Undergraduate',
                checked: nil,
              },
              {
                value: 'HE,HES,SD,SS,SC,SSC,TA',
                label: 'Postgraduate',
                checked: nil,
              },
            ],
          },
          {
            type: :checkboxes,
            heading: '<h3 class="govuk-heading-m govuk-!-margin-bottom-0">Candidate’s visa requirements</h3>',
            name: 'visa_sponsorship',
            options: [
              {
                value: 'required',
                label: 'Needs a visa',
                checked: nil,
              },
              {
                value: 'not required',
                label: 'Does not need a visa',
                checked: nil,
              },
            ],
          },
        ])
      end
    end
  end

  describe '#applied_filters' do
    it 'returns the applied filters' do
      filter_params = {
        'original_location' => 'Manchester',
        'visa_sponsorship' => ['required'],
      }
      current_provider_user = create(:provider_user)
      filter = described_class.new(filter_params:, current_provider_user:)

      expect(filter.applied_filters).to eq(
        {
          original_location: 'Manchester',
          visa_sponsorship: ['required'],
          origin: [53.4706519, -2.2954452],
        }.with_indifferent_access,
      )
    end
  end

  describe '#applied_location_search?' do
    it 'returns true if location search is applied' do
      filter_params = { 'original_location' => 'Manchester' }
      current_provider_user = create(:provider_user)
      filter = described_class.new(filter_params:, current_provider_user:)

      expect(filter.applied_location_search?).to be_truthy
    end

    it 'returns false if location search is applied' do
      current_provider_user = create(:provider_user)
      filter = described_class.new(filter_params: {}, current_provider_user:)

      expect(filter.applied_location_search?).to be_falsey
    end
  end
end

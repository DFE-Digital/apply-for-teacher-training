require 'rails_helper'

RSpec.describe SupportInterface::CandidatePoolFilter do
  include Rails.application.routes.url_helpers

  describe '#filters' do
    it 'returns the filters' do
      filter = described_class.new(filter_params: {})

      expect(filter.filters).to eq([
        {
          type: :location_search,
          heading: 'Town, city or postcode:',
          name: 'location_search',
          original_location: nil,
          title: 'Candidate location preferences',
          path_to_location_suggestions: support_interface_location_suggestions_path,
        },
        {
          type: :checkbox_filter,
          heading: 'Subjects previously applied to',
          name: 'subject_ids',
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
              value: 'undergraduate',
              label: 'Undergraduate',
              checked: nil,
            },
            {
              value: 'postgraduate',
              label: 'Postgraduate',
              checked: nil,
            },
          ],
        },
        {
          type: :checkboxes,
          heading: '<h3 class="govuk-heading-m govuk-!-margin-bottom-0">Candidate visa requirements</h3>',
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

  describe '#applied_filters' do
    it 'returns the applied filters' do
      filter_params = {
        original_location: 'Manchester',
        visa_sponsorship: ['required'],
      }
      filter = described_class.new(filter_params:)

      expect(filter.applied_filters).to eq(
        {
          original_location: 'Manchester',
          visa_sponsorship: ['required'],
          origin: [53.4706519, -2.2954452],
        },
      )
    end
  end

  describe '#applied_location_search?' do
    it 'returns true if location search is applied' do
      filter_params = { original_location: 'Manchester' }
      filter = described_class.new(filter_params:)

      expect(filter.applied_location_search?).to be_truthy
    end

    it 'returns false if location search is applied' do
      filter = described_class.new(filter_params: {})

      expect(filter.applied_location_search?).to be_falsey
    end
  end
end

require 'rails_helper'

RSpec.describe ProviderInterface::CandidatePoolFilter do
  describe '#filters' do
    it 'returns the filters' do
      filter = described_class.new(filter_params: {})

      expect(filter.filters).to eq([
        {
          type: :location_search,
          heading: 'Search radius',
          name: 'location_search',
          hint: "Candidate's last course location",
          radius_values: [1, 5, 10, 15, 20, 25, 50, 100, 200],
          within: nil,
          original_location: nil,
        },
        {
          type: :checkbox_filter,
          heading: 'Subject',
          name: 'subject',
          options: [],
          hide_tags: true,
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
              value: 'HE,HES,SD,SS,SC,SSC,TA',
              label: 'Undergraduate',
              checked: nil,
            },
            {
              value: 'TDA',
              label: 'Postgraduate',
              checked: nil,
            },
          ],
        },
        {
          type: :checkboxes,
          heading: 'Visa sponsorship',
          name: 'visa_sponsorship',
          options: [
            {
              value: 'required',
              label: 'Required',
              checked: nil,
            },
            {
              value: 'not required',
              label: 'Not required',
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
        within: 10,
        original_location: 'Manchester',
        visa_sponsorship: ['required'],
      }
      filter = described_class.new(filter_params:)

      expect(filter.applied_filters).to eq(
        {
          within: 10,
          original_location: 'Manchester',
          visa_sponsorship: ['required'],
          origin: [51.4524877, -0.1204749],
        },
      )
    end
  end

  describe '#applied_location_search?' do
    it 'returns true if location search is applied' do
      filter_params = {
        within: 10,
        original_location: 'Manchester',
      }
      filter = described_class.new(filter_params:)

      expect(filter.applied_location_search?).to be_truthy
    end

    it 'returns false if location search is applied' do
      filter = described_class.new(filter_params: {})

      expect(filter.applied_location_search?).to be_falsey
    end
  end
end

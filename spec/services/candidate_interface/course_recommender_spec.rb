require 'rails_helper'

RSpec.describe CandidateInterface::CoursesRecommender do
  describe '.recommended_courses_url' do
    it 'returns the URL for the recommended courses page' do
      candidate = build(:candidate)

      expect(described_class.recommended_courses_url(candidate:)).to be_falsey
    end

    it 'returns the query parameters for the recommended courses page' do
      candidate = build(:candidate)

      allow_any_instance_of(described_class).to receive(:recommend?).and_return(true)

      uri = URI(described_class.recommended_courses_url(candidate:))
      query_parameters = Rack::Utils.parse_query(uri.query)

      expect(query_parameters).to eq({
        'can_sponsor_visa' => 'true',
        'degree_required' => 'show_all_courses', # show_all_courses two_two third_class not_required
        'funding_type' => 'salary,apprenticeship,fee',
        'latitude' => '', # for location
        'longitude' => '', # for location
        'qualification[]' => %w[
          pgde
          pgce
          pgce_with_qts
          pgde_with_qts
          qts
        ],
        'radius' => '20', # for location
        'study_type[]' => %w[
          full_time
          part_time
        ],
        'subjects[]' => %w[
          00
          01
        ], # subject codes
      })
    end
  end
end

require 'rails_helper'

RSpec.describe CandidateInterface::CoursesRecommender do
  describe '.recommended_courses_url' do
    it 'returns the URL for the recommended courses page' do
      candidate = build(:candidate)

      expect(described_class.recommended_courses_url(candidate:)).to be_falsey
    end
  end
end

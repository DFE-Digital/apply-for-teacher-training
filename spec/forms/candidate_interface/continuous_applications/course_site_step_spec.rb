require 'rails_helper'

RSpec.describe CandidateInterface::ContinuousApplications::CourseSiteStep do
  subject(:which_course_are_you_applying_to_step) do
    described_class.new(provider_id:, course_id:, course_option_id:)
  end

  let(:provider_id) { nil }
  let(:course_id) { nil }
  let(:course_option_id) { nil }

  describe 'validations' do
    it 'errors on course option id' do
      expect(which_course_are_you_applying_to_step).to validate_presence_of(:course_option_id)
    end
  end

  describe '#next_step' do
    it 'returns :course_study_mode' do
      expect(which_course_are_you_applying_to_step.next_step).to be(:course_review)
    end
  end
end

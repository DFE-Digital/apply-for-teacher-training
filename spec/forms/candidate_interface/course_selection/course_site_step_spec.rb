require 'rails_helper'

RSpec.describe CandidateInterface::CourseSelection::CourseSiteStep do
  subject(:course_site_step) do
    described_class.new(provider_id:, course_id:, course_option_id:)
  end

  let(:provider_id) { nil }
  let(:course_id) { nil }
  let(:course_option_id) { nil }

  describe '.route_name' do
    subject { course_site_step.class.route_name }

    it { is_expected.to eq('candidate_interface_continuous_applications_course_site') }
  end

  describe 'validations' do
    it 'errors on course option id' do
      expect(course_site_step).to validate_presence_of(:course_option_id)
    end
  end

  describe '#next_step' do
    it 'returns :course_study_mode' do
      expect(course_site_step.next_step).to be(:course_review)
    end
  end
end

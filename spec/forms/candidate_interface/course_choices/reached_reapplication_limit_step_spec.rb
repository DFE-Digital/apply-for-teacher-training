require 'rails_helper'

RSpec.describe CandidateInterface::CourseChoices::ReachedReapplicationLimitStep do
  subject { described_class.new.class.route_name }

  describe '.route_name' do
    it { is_expected.to eq('candidate_interface_course_choices_reached_reapplication_limit') }
  end
end

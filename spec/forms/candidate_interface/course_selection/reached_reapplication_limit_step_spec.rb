require 'rails_helper'

RSpec.describe CandidateInterface::CourseSelection::ReachedReapplicationLimitStep do
  subject { described_class.new.class.route_name }

  describe '.route_name' do
    it { is_expected.to eq('candidate_interface_continuous_applications_reached_reapplication_limit') }
  end
end

require 'rails_helper'

RSpec.describe GenerateTestApplications do
  before do
    create(:course_option)
  end

  it 'generates 11 test candidates with applications in various states' do
    GenerateTestApplications.new.perform
    expect(Candidate.count).to be 11
    expect(ApplicationChoice.pluck(:status)).to include(
      'awaiting_provider_decision',
      'awaiting_references',
      'offer',
      'rejected',
      'declined',
      'withdrawn',
      'recruited',
      'enrolled',
    )
  end
end

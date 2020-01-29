require 'rails_helper'

RSpec.describe GenerateTestApplications do
  before do
    create(:course_option, course: create(:course, :open_on_apply))
    create(:course_option, course: create(:course, :open_on_apply))
  end

  it 'generates 12 test candidates with applications in various states' do
    GenerateTestApplications.new.perform

    expect(Candidate.count).to be 12
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

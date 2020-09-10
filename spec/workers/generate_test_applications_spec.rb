require 'rails_helper'

RSpec.describe GenerateTestApplications do
  it 'generates test candidates with applications in various states', sidekiq: true do
    create(:course_option, course: create(:course, :open_on_apply))
    create(:course_option, course: create(:course, :open_on_apply))
    create(:course_option, course: create(:course, :open_on_apply))

    slack_request = stub_request(:post, 'https://example.com')

    ClimateControl.modify(STATE_CHANGE_SLACK_URL: 'https://example.com') do
      GenerateTestApplications.new.perform
    end

    expect(slack_request).not_to have_been_made

    expect(ApplicationChoice.pluck(:status)).to include(
      'unsubmitted',
      'awaiting_provider_decision',
      'awaiting_references',
      'offer',
      'rejected',
      'declined',
      'withdrawn',
      'recruited',
    )
    # there is at least one unsubmitted application to a full course
    expect(ApplicationChoice.where(status: 'unsubmitted').map(&:course_option).select(&:no_vacancies?)).not_to be_empty
    # there is at least one awaiting_references application to a full course
    expect(ApplicationChoice.where(status: 'awaiting_references').map(&:course_option).select(&:no_vacancies?)).not_to be_empty
  end
end

require 'rails_helper'

RSpec.describe GenerateTestApplications do
  it 'generates test candidates with applications in various states', sidekiq: true do
    create(:course_option, course: create(:course, :open_on_apply, recruitment_cycle_year: 2020))
    create(:course_option, course: create(:course, :open_on_apply, recruitment_cycle_year: 2020))
    create(:course_option, course: create(:course, :open_on_apply, recruitment_cycle_year: 2020))

    create(:course_option, course: create(:course, :open_on_apply, recruitment_cycle_year: 2021))
    create(:course_option, course: create(:course, :open_on_apply, recruitment_cycle_year: 2021))
    create(:course_option, course: create(:course, :open_on_apply, recruitment_cycle_year: 2021))

    slack_request = stub_request(:post, 'https://example.com')

    ClimateControl.modify(STATE_CHANGE_SLACK_URL: 'https://example.com') do
      described_class.new.perform
    end

    expect(slack_request).not_to have_been_made

    expect(ApplicationChoice.pluck(:status)).to include(
      'unsubmitted',
      'awaiting_provider_decision',
      'offer',
      'rejected',
      'declined',
      'withdrawn',
      'recruited',
    )

    # there is at least one unsubmitted application to a full course
    expect(ApplicationChoice.where(status: 'unsubmitted').map(&:course_option).select(&:no_vacancies?)).not_to be_empty

    # there is at least one successful carried over application
    expect(ApplicationForm.joins(:application_choices).where('application_choices.status': 'offer', phase: 'apply_1').where.not(previous_application_form_id: nil)).not_to be_empty

    # there is at least one successful apply again application
    expect(ApplicationForm.joins(:application_choices).where('application_choices.status': 'offer', phase: 'apply_2').where.not(previous_application_form_id: nil)).not_to be_empty

    expect(ApplicationChoice.cancelled.first.application_form.application_references.feedback_requested).to be_empty
  end
end

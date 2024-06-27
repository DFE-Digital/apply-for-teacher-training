require 'rails_helper'

RSpec.describe GenerateTestApplications do
  include CycleTimetableHelper

  it 'generates test candidates with applications in various states', :sidekiq, time: mid_cycle do
    previous_cycle = RecruitmentCycle.previous_year
    current_cycle = RecruitmentCycle.current_year

    # necessary to test 'cancelled' state
    create(:course_option, course: create(:course, :open, recruitment_cycle_year: 2020))

    create(:course_option, course: create(:course, :open, recruitment_cycle_year: previous_cycle))
    create(:course_option, course: create(:course, :open, recruitment_cycle_year: previous_cycle))
    create(:course_option, course: create(:course, :open, recruitment_cycle_year: previous_cycle))

    create(:course_option, course: create(:course, :open, recruitment_cycle_year: current_cycle))
    create(:course_option, course: create(:course, :open, recruitment_cycle_year: current_cycle))
    create(:course_option, course: create(:course, :open, recruitment_cycle_year: current_cycle))
    create(:course_option, course: create(:course, :open, recruitment_cycle_year: current_cycle))
    create(:course_option, course: create(:course, :open, recruitment_cycle_year: current_cycle))
    create(:course_option, course: create(:course, :open, recruitment_cycle_year: current_cycle))

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
  end

  it 'generates test applications for the next cycle', :sidekiq do
    current_cycle = RecruitmentCycle.current_year
    provider = create(:provider)

    create(:course_option, course: create(:course, :open, recruitment_cycle_year: current_cycle, provider:))
    create(:course_option, course: create(:course, :open, recruitment_cycle_year: current_cycle, provider:))
    create(:course_option, course: create(:course, :open, recruitment_cycle_year: current_cycle, provider:))
    create(:course_option, course: create(:course, :open, recruitment_cycle_year: current_cycle, provider:))
    create(:course_option, course: create(:course, :open, recruitment_cycle_year: current_cycle, provider:))

    ClimateControl.modify(STATE_CHANGE_SLACK_URL: 'https://example.com') do
      described_class.new.perform(true)
    end

    expect(ApplicationChoice.pluck(:status)).to include(
      'awaiting_provider_decision',
      'pending_conditions',
      'offer',
      'rejected',
      'offer_withdrawn',
      'offer_deferred',
      'recruited',
    )
  end
end

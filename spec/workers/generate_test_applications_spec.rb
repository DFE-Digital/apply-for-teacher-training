require 'rails_helper'

RSpec.describe GenerateTestApplications do
  include CycleTimetableHelper

  it 'generates test candidates with applications in various states', :sidekiq, time: mid_cycle do
    previous_cycle = previous_year
    current_cycle = current_year

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


      described_class.new.perform


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

  it 'generates undergraduate test applications', :sidekiq, time: mid_cycle do
    current_cycle = current_year
    previous_cycle = previous_year
    provider = create(:provider)

    create(:course_option, course: create(:course, :open, recruitment_cycle_year: previous_cycle))

    create(:course_option, course: create(:course, :open, recruitment_cycle_year: previous_cycle))
    create(:course_option, course: create(:course, :open, recruitment_cycle_year: previous_cycle))
    create(:course_option, course: create(:course, :open, recruitment_cycle_year: previous_cycle))

    create(:course_option, course: create(:course, :open, recruitment_cycle_year: current_cycle, provider:))
    create(:course_option, course: create(:course, :open, recruitment_cycle_year: current_cycle, provider:))
    create(:course_option, course: create(:course, :open, recruitment_cycle_year: current_cycle, provider:))
    create(:course_option, course: create(:course, :open, recruitment_cycle_year: current_cycle, provider:))
    create(:course_option, course: create(:course, :open, recruitment_cycle_year: current_cycle, provider:))

      described_class.new.perform

    expect(
      ApplicationForm
      .joins(application_choices: { course_option: :course })
      .where("courses.program_type = 'TDA'"),
    ).not_to be_empty
  end

  it 'generates test applications for the next cycle', :sidekiq, time: mid_cycle do
    current_cycle = current_year
    provider = create(:provider)

    create(:course_option, course: create(:course, :open, recruitment_cycle_year: current_cycle, provider:))
    create(:course_option, course: create(:course, :open, recruitment_cycle_year: current_cycle, provider:))
    create(:course_option, course: create(:course, :open, recruitment_cycle_year: current_cycle, provider:))
    create(:course_option, course: create(:course, :open, recruitment_cycle_year: current_cycle, provider:))
    create(:course_option, course: create(:course, :open, recruitment_cycle_year: current_cycle, provider:))

      described_class.new.perform(true)

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

require 'rails_helper'

RSpec.feature 'Process Stale applications', :continuous_applications, :sidekiq do
  include CourseOptionHelpers

  scenario 'An application is marked as inactive', :with_audited do
    given_there_is_a_provider_user_for_the_provider_course
    and_the_continuous_applications_feature_is_enabled
    and_there_is_a_candidate
    and_an_application_is_ready_to_be_marked_as_inactive
    when_we_process_stale_applications
    then_the_application_should_be_inactive
  end

  def given_there_is_a_provider_user_for_the_provider_course
    @course_option = course_option_for_provider_code(provider_code: 'ABC')
    @provider_user = Provider.find_by(code: 'ABC').provider_users.first
  end

  def and_the_continuous_applications_feature_is_enabled
    FeatureFlag.activate(:continuous_applications)
  end

  def and_there_is_a_candidate
    @candidate = create(:candidate)
  end

  def and_an_application_is_ready_to_be_marked_as_inactive
    @application_choice =
      create(
        :application_choice,
        status: 'awaiting_provider_decision',
        reject_by_default_at: Time.zone.today,
        course_option: @course_option,
        application_form:
          create(
            :completed_application_form,
            submitted_at: Time.zone.today,
            candidate: @candidate,
          ),
      )
  end

  def when_we_process_stale_applications
    travel_temporarily_to(10.minutes.from_now) do
      ProcessStaleApplicationsWorker.perform_async
    end
  end

  def then_the_application_should_be_inactive
    expect(@application_choice.reload.status).to eq('inactive')
  end
end

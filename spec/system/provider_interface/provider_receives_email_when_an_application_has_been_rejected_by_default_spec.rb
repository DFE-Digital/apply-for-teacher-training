require 'rails_helper'

RSpec.feature 'An application has been rejected by default' do
  include CourseOptionHelpers

  scenario 'the provider receives email', with_audited: true do
    given_i_am_a_provider_user_with_a_provider
    and_there_is_a_candidate
    and_an_application_is_ready_to_reject_by_default

    when_the_application_is_rejected_by_default

    then_i_should_receive_an_email
    and_the_candidate_should_receive_an_email
  end

  def given_i_am_a_provider_user_with_a_provider
    @course_option = course_option_for_provider_code(provider_code: 'ABC')
    @provider_user = Provider.find_by(code: 'ABC').provider_users.first
  end

  def and_there_is_a_candidate
    @candidate = create :candidate
  end

  def and_an_application_is_ready_to_reject_by_default
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

  def when_the_application_is_rejected_by_default
    RejectApplicationsByDefaultWorker.new.perform
  end

  def then_i_should_receive_an_email
    open_email(@provider_user.email_address)

    expect(current_email.subject).to include(t('provider_application_rejected_by_default.email.subject',
                                               candidate_name: @application_choice.application_form.full_name))
  end

  def and_the_candidate_should_receive_an_email
    open_email(@candidate.email_address)

    expect(current_email.subject).to include(
      t(
        'candidate_mailer.application_rejected_by_default.subject',
        provider_name: @application_choice.provider.name,
      ),
    )
  end
end

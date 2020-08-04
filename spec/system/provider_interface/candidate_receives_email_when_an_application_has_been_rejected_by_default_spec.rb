require 'rails_helper'

RSpec.feature 'An application has been rejected by default' do
  include CourseOptionHelpers

  scenario 'the candidate receives email', with_audited: true do
    given_i_am_a_candidate
    and_an_application_is_ready_to_reject_by_default

    when_the_application_is_rejected_by_default

    then_i_should_receive_an_email
  end

  def given_i_am_a_candidate
    @candidate = create :candidate
  end

  def and_an_application_is_ready_to_reject_by_default
    @application_choice =
      create(
        :application_choice,
        status: 'awaiting_provider_decision',
        reject_by_default_at: Time.zone.today,
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
    open_email(@candidate.email_address)

    expect(current_email.subject).to include(
      t(
        'candidate_mailer.application_rejected_by_default.all_rejected.subject',
        provider_name: @application_choice.provider.name,
      ),
    )
  end
end

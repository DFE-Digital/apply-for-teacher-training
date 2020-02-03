require 'rails_helper'

RSpec.feature 'An application has been rejected by default' do
  include CourseOptionHelpers

  scenario 'the provider receives email', with_audited: true do
    given_i_am_a_provider_user_with_a_provider
    and_an_application_is_ready_to_reject_by_default

    when_the_application_is_rejected_by_default

    then_i_should_receive_an_email_with_a_link_to_the_application
    and_an_audit_comment_has_submitted
  end

  def given_i_am_a_provider_user_with_a_provider
    @course_option = course_option_for_provider_code(provider_code: 'ABC')
    @provider_user = Provider.find_by(code: 'ABC').provider_users.first
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
          ),
      )
  end

  def when_the_application_is_rejected_by_default
    RejectApplicationsByDefaultWorker.new.perform
  end

  def then_i_should_receive_an_email_with_a_link_to_the_application
    open_email(@provider_user.email_address)

    expect(current_email.subject).to include(t('provider_application_rejected_by_default.email.subject',
                                               candidate_name: @application_choice.application_form.full_name))

    expect(current_email.body).to include("http://localhost:3000/provider/applications/#{@application_choice.id}")
  end

  def and_an_audit_comment_has_submitted
    expected_audit_comment =
      'Rejected by default email have been sent to the provider user' +
      " #{@provider_user.email_address} for application #{@application_choice.course.name_and_code}."

    expect(@application_choice.application_form.audits.last.comment).to eq(expected_audit_comment)
  end
end

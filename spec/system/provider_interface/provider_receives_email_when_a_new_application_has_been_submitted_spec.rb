require 'rails_helper'

RSpec.feature 'A new application has been submitted' do
  include CourseOptionHelpers

  scenario 'the provider receives email', with_audited: true do
    given_i_am_a_provider_user_with_a_provider
    and_a_candidate_submited_their_application

    when_the_application_is_delivered_to_my_provider

    then_i_should_receive_an_email_with_a_link_to_the_application
    and_an_audit_comment_has_submitted
  end

  def given_i_am_a_provider_user_with_a_provider
    @course_option = course_option_for_provider_code(provider_code: 'ABC')
    @provider_user = Provider.find_by(code: 'ABC').provider_users.first
  end

  def and_a_candidate_submited_their_application
    @application_choice =
      create(
        :application_choice,
        status: 'application_complete',
        edit_by: Time.zone.today,
        course_option: @course_option,
        application_form:
          create(
            :completed_application_form,
            submitted_at: Time.zone.today,
          ),
      )
  end

  def when_the_application_is_delivered_to_my_provider
    SendApplicationsToProviderWorker.new.perform
  end

  def then_i_should_receive_an_email_with_a_link_to_the_application
    open_email(@provider_user.email_address)

    expect(current_email.subject).to include("Application received for #{@application_choice.course.name_and_code}")

    expect(current_email.body).to include("http://localhost:3000/provider/applications/#{@application_choice.id}")
  end

  def and_an_audit_comment_has_submitted
    expected_audit_comment =
      'New application email have been sent to the provider user' +
      " (#{@provider_user.email_address}) for application (#{@application_choice.course.name})" +
      " (#{@application_choice.course.code})."

    expect(@application_choice.application_form.audits.last.comment).to eq(expected_audit_comment)
  end
end

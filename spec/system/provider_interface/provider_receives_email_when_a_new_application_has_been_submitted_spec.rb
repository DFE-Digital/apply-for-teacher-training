require 'rails_helper'

RSpec.feature 'A new application has been submitted' do
  include CourseOptionHelpers

  scenario 'the provider receives email' do
    given_i_am_a_provider_user_with_a_provider
    and_a_candidate_submited_their_application

    when_the_application_is_delivered_to_my_provider

    then_i_should_receive_an_email_with_a_link_to_the_application
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
    open_email(@application_choice.provider.provider_users.first.email_address)

    expect(current_email.subject).to include(t('provider_application_submitted.email.subject',
                                               course_name: @application_choice.course.name,
                                                course_code: @application_choice.course.code))

    expect(current_email.body).to include("http://localhost:3000/provider/applications/#{@application_choice.id}")
  end
end

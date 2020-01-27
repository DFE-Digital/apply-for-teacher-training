require 'rails_helper'

RSpec.feature 'Provider makes an offer' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'Provider fails to select a response (offer/reject)' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_application_choices_exist_for_my_provider
    and_i_am_permitted_to_see_applications_for_my_provider
    and_i_sign_in_to_the_provider_interface

    when_i_respond_to_an_application
    and_i_try_to_proceed_without_selecting_a_response
    then_i_see_an_error_message_prompting_for_a_response
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_application_choices_exist_for_my_provider
    course_option = course_option_for_provider_code(provider_code: 'ABC')
    @application_awaiting_provider_decision = create(:application_choice, status: 'awaiting_provider_decision', course_option: course_option, application_form: create(:completed_application_form, first_name: 'Alice', last_name: 'Wunder'))
  end

  def and_i_am_permitted_to_see_applications_for_my_provider
    provider_user_exists_in_apply_database
  end

  def when_i_respond_to_an_application
    visit provider_interface_application_choice_respond_path(
      @application_awaiting_provider_decision.id,
    )
  end

  def and_i_try_to_proceed_without_selecting_a_response
    click_on 'Continue'
  end

  def then_i_see_an_error_message_prompting_for_a_response
    expect(page).to have_current_path(
      provider_interface_application_choice_respond_path(
        @application_awaiting_provider_decision.id,
      ),
    )
    expect(page).to have_content 'Select if you want to make an offer or reject the application'
  end
end

require 'rails_helper'

RSpec.feature 'Confirm conditions not met' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'Provider user confirms offer conditions have not been met by the candidate' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_an_authorised_provider_user
    and_i_can_access_the_provider_interface

    when_i_navigate_to_an_offer_accepted_by_the_candidate
    and_click_on_confirm_conditions
    and_select_they_have_not_met_the_conditions
    and_confirm_my_selection_in_the_next_page

    then_i_get_feedback_that_my_action_succeeded
    and_i_am_back_on_the_application_page
    and_the_application_status_is_conditions_not_met
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_an_authorised_provider_user
    @provider = create(:provider, :with_signed_agreement)
    create(:provider_user, providers: [@provider], dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
  end

  def and_i_can_access_the_provider_interface
    provider_signs_in_using_dfe_sign_in
    visit provider_interface_applications_path
    expect(page).to have_current_path provider_interface_applications_path
  end

  def when_i_navigate_to_an_offer_accepted_by_the_candidate
    course_option = course_option_for_provider_code(provider_code: @provider.code)
    @application_form = create(
      :completed_application_form,
      first_name: 'John',
      last_name: 'Smith',
    )
    @application_choice = create(
      :application_choice,
      :with_accepted_offer,
      course_option: course_option,
      application_form: @application_form,
    )
    visit provider_interface_application_choice_path(@application_choice.id)
  end

  def and_click_on_confirm_conditions
    click_on 'Confirm conditions'
  end

  def and_select_they_have_not_met_the_conditions
    within_fieldset('Has the candidate met all of the conditions?') do
      choose 'No'
    end

    click_on 'Continue'
  end

  def and_confirm_my_selection_in_the_next_page
    click_on 'Yes I’m sure – they did not meet the conditions'
  end

  def then_i_get_feedback_that_my_action_succeeded
    expect(page).to have_content 'Conditions successfully marked as not met'
  end

  def and_i_am_back_on_the_application_page
    expect(page).to have_current_path provider_interface_application_choice_path(@application_choice.id)
  end

  def and_the_application_status_is_conditions_not_met
    expect(@application_choice.reload.conditions_not_met?).to be_truthy
    expect(page).to have_content 'Conditions not met'
  end
end

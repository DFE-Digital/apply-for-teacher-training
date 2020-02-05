require 'rails_helper'

RSpec.feature 'Confirm conditions met' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'Provider user confirms offer conditions have been met by the candidate' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_an_authorised_provider_user
    and_i_can_access_the_provider_interface
    and_the_confirm_conditions_feature_flag_is_on

    when_i_navigate_to_an_offer_accepted_by_the_candidate
    and_click_on_confirm_conditions
    and_select_they_have_met_the_conditions
    and_confirm_my_selection_in_the_next_page

    then_i_get_feedback_that_my_action_succeeded
    and_i_am_back_on_the_application_page
    and_the_candidate_is_recruited
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

  def and_the_confirm_conditions_feature_flag_is_on
    FeatureFlag.activate('confirm_conditions')
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

  def and_select_they_have_met_the_conditions
    within_fieldset('Has the candidate met all of the conditions?') do
      choose 'Yes, they’ve met all of the conditions'
    end

    click_on 'Continue'
  end

  def and_confirm_my_selection_in_the_next_page
    click_on 'Yes I’m sure – they met the conditions'
  end

  def then_i_get_feedback_that_my_action_succeeded
    expect(page).to have_content 'Conditions successfully marked as met'
  end

  def and_i_am_back_on_the_application_page
    expect(page).to have_current_path provider_interface_application_choice_path(@application_choice.id)
  end

  def and_the_candidate_is_recruited
    expect(@application_choice.reload.recruited?).to be_truthy
    expect(page).to have_content 'Recruited'
  end
end

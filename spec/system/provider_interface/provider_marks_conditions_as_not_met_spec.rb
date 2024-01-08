require 'rails_helper'

RSpec.feature 'Confirm conditions met' do
  include CourseOptionHelpers
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  scenario 'Provider user confirms offer conditions have been met by the candidate' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_an_authorised_provider_user
    and_i_can_access_the_provider_interface

    when_i_navigate_to_an_offer_accepted_by_the_candidate
    and_i_navigate_to_the_offer_tab
    and_click_on_confirm_conditions
    then_i_should_see_a_summary_of_the_conditions

    when_i_select_they_have_not_met_one_of_the_conditions
    and_confirm_my_selection_in_the_next_page

    then_i_get_feedback_that_my_action_succeeded
    and_i_am_back_on_the_application_page
    and_the_candidate_is_conditions_not_met
    and_the_candidate_receives_an_email_notification
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_an_authorised_provider_user
    @provider = create(:provider)
    create(:provider_user, providers: [@provider], dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
    permit_make_decisions!
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
    @conditions = create_list(:text_condition, 3)
    @application_choice = create(
      :application_choice,
      :accepted,
      offer: create(:offer, conditions: @conditions),
      current_course_option: course_option,
      application_form: @application_form,
    )
    visit provider_interface_application_choice_path(@application_choice)
  end

  def and_i_navigate_to_the_offer_tab
    click_link_or_button 'Offer'
  end

  def and_click_on_confirm_conditions
    click_link_or_button 'Update status of conditions'
  end

  def then_i_should_see_a_summary_of_the_conditions
    within '.app-box' do
      @conditions.each do |condition|
        expect(page).to have_content(condition.text)
      end
    end
  end

  def when_i_select_they_have_not_met_one_of_the_conditions
    within_fieldset(@conditions.sample.text) do
      choose 'Not met'
    end

    click_link_or_button t('continue')
  end

  def and_confirm_my_selection_in_the_next_page
    click_link_or_button 'Mark conditions as not met'
  end

  def then_i_get_feedback_that_my_action_succeeded
    expect(page).to have_content 'Conditions marked as not met'
  end

  def and_i_am_back_on_the_application_page
    expect(page).to have_current_path provider_interface_application_choice_path(@application_choice)
  end

  def and_the_candidate_is_conditions_not_met
    expect(@application_choice.reload.conditions_not_met?).to be_truthy
    expect(page).to have_content 'Conditions not met'
  end

  def and_the_candidate_receives_an_email_notification
    open_email(@application_choice.application_form.candidate.email_address)
    expect(current_email.subject).to have_content 'You did not meet the offer conditions for'
  end
end

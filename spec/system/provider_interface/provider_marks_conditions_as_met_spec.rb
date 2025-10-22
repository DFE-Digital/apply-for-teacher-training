require 'rails_helper'

RSpec.describe 'Confirm conditions met' do
  include CourseOptionHelpers
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  scenario 'Provider user confirms offer conditions have been met by the candidate' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_an_authorised_provider_user
    and_i_can_access_the_provider_interface

    when_i_navigate_to_an_offer_accepted_by_the_candidate
    and_i_navigate_to_the_offer_tab

    when_i_click_on_confirm_conditions
    then_i_see_a_summary_of_the_standard_conditions
    then_i_see_a_summary_of_the_ske_condition

    when_i_select_they_have_met_all_the_standard_conditions
    when_i_select_they_have_met_the_ske_conditions
    and_confirm_my_selection_in_the_next_page

    then_i_get_feedback_that_my_action_succeeded
    and_i_am_back_on_the_application_page
    and_the_candidate_is_recruited
    and_the_candidate_receives_an_email_notification
    and_i_navigate_to_the_offer_tab
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
    @ske_condition = create(:ske_condition, status: 'pending')
    @application_choice = create(
      :application_choice,
      :accepted,
      offer: create(:offer, conditions: @conditions + [@ske_condition]),
      current_course_option: course_option,
      application_form: @application_form,
    )
    visit provider_interface_application_choice_path(@application_choice)
  end

  def and_i_navigate_to_the_offer_tab
    click_link_or_button 'Offer'
  end

  def when_i_click_on_confirm_conditions
    click_link_or_button 'Update status of conditions'
  end

  def then_i_see_a_summary_of_the_standard_conditions
    within '.app-box' do
      @conditions.each do |condition|
        expect(page).to have_content(condition.text)
      end
    end
  end

  def then_i_see_a_summary_of_the_ske_condition
    within '.app-box' do
      expect(page).to have_content(@ske_condition.subject)
    end
  end

  def when_i_select_they_have_met_all_the_standard_conditions
    @conditions.each do |condition|
      within_fieldset(condition.text) do
        choose 'Met'
      end
    end
  end

  def when_i_select_they_have_met_the_ske_conditions
    within_fieldset(@ske_condition.text) do
      choose 'Met'
    end

    click_link_or_button t('continue')
  end

  def and_confirm_my_selection_in_the_next_page
    click_link_or_button 'Mark conditions as met and tell candidate'
  end

  def then_i_get_feedback_that_my_action_succeeded
    expect(page).to have_content 'Conditions marked as met'
  end

  def and_i_am_back_on_the_application_page
    expect(page).to have_current_path provider_interface_application_choice_path(@application_choice)
  end

  def and_the_candidate_is_recruited
    expect(@application_choice.reload.recruited?).to be_truthy
    expect(page).to have_content 'Recruited'
  end

  def and_the_candidate_receives_an_email_notification
    open_email(@application_choice.application_form.candidate.email_address)

    expect(current_email.subject).to have_content 'You have met your conditions to study'
  end
end

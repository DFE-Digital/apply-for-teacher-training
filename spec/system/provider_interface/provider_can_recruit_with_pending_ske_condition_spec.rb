require 'rails_helper'

NUMBER_OF_TEXT_CONDITIONS = 3

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
    then_i_do_not_see_button_to_recruit_with_pending_conditions

    when_i_click_on_confirm_conditions
    then_i_see_a_summary_of_the_conditions

    when_i_change_the_status_of_the_text_conditions_to_met
    and_confirm_my_selection_in_the_next_page

    then_i_get_feedback_that_my_action_succeeded

    when_i_revisit_the_offer
    and_i_navigate_to_the_offer_tab
    then_i_see_button_to_recruit_with_pending_conditions

    when_i_click_recruit_with_pending_conditions
    then_i_see_the_recruit_with_pending_conditions_confirmation_page

    when_i_click_continue
    then_i_see_a_validation_error
    and_the_candidate_is_still_pending_conditions

    when_i_select_no_and_click_continue
    then_i_see_the_offer_page_without_a_flash_message
    and_the_candidate_is_still_pending_conditions

    when_i_click_recruit_with_pending_conditions
    and_i_select_yes_and_click_continue
    then_i_see_the_offer_page_with_a_flash_message
    and_the_application_is_now_recruited

    when_i_log_in_as_the_candidate
    then_i_see_the_offer_page_with_a_message_about_pending_ske_conditions

    when_i_go_back_as_the_provider_and_open_application_choice
    and_i_navigate_to_the_offer_tab
    and_i_click_on_confirm_conditions
    then_i_see_a_summary_of_the_conditions

    when_i_change_the_status_of_the_ske_condition_to_met
    and_confirm_all_conditions_met_on_the_next_page
    and_i_navigate_to_the_offer_tab
    then_i_see_application_is_recruited_with_all_conditions_met
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
    @conditions = create_list(:text_condition, NUMBER_OF_TEXT_CONDITIONS)
    @conditions << create(:ske_condition)
    @application_choice = create(
      :application_choice,
      :accepted,
      offer: create(:offer, conditions: @conditions),
      current_course_option: course_option,
      application_form: @application_form,
    )
    @application_choice.provider.update(provider_type: :scitt)
    @application_choice.course.update(start_date: 2.months.from_now)
    visit provider_interface_application_choice_path(@application_choice)
  end

  def when_i_revisit_the_offer
    visit provider_interface_application_choice_path(@application_choice)
  end

  def and_i_navigate_to_the_offer_tab
    click_link_or_button 'Offer'
  end

  def then_i_do_not_see_button_to_recruit_with_pending_conditions
    expect(page).to have_no_button('Recruit candidate with pending conditions')
  end

  def then_i_see_button_to_recruit_with_pending_conditions
    expect(page).to have_button('Recruit candidate with pending conditions')
  end

  def when_i_click_on_confirm_conditions
    click_link_or_button 'Update status of conditions'
  end
  alias_method :and_i_click_on_confirm_conditions, :when_i_click_on_confirm_conditions

  def when_i_click_recruit_with_pending_conditions
    click_link_or_button 'Recruit candidate with pending conditions'
  end

  def then_i_see_a_summary_of_the_conditions
    within '.app-box' do
      @conditions.each do |condition|
        expect(page).to have_content(condition.text)
      end
    end
  end

  def when_i_change_the_status_of_the_text_conditions_to_met
    @conditions.take(NUMBER_OF_TEXT_CONDITIONS).each do |condition|
      within_fieldset(condition.text) do
        choose 'Met'
      end
    end

    click_link_or_button t('continue')
  end

  def when_i_change_the_status_of_the_ske_condition_to_met
    within_fieldset(@conditions.last.text) do
      choose 'Met'
    end

    click_link_or_button t('continue')
  end

  def and_confirm_my_selection_in_the_next_page
    click_link_or_button 'Update status'
  end

  def then_i_get_feedback_that_my_action_succeeded
    expect(page).to have_content 'Status of conditions updated'
  end

  def and_i_am_back_on_the_application_page
    expect(page).to have_current_path provider_interface_application_choice_path(@application_choice)
  end

  def and_the_candidate_is_still_pending_conditions
    expect(@application_choice.reload.pending_conditions?).to be_truthy
    expect(page).to have_content('Conditions pending')
  end

  def then_i_see_the_recruit_with_pending_conditions_confirmation_page
    expect(page).to have_content('Do you want to recruit the candidate with pending conditions?')
  end

  def when_i_click_continue
    click_link_or_button('Continue')
  end

  def then_i_see_a_validation_error
    expect(page).to have_current_path(
      provider_interface_application_choice_offer_recruit_with_pending_conditions_path(
        application_choice_id: @application_choice.id,
      ),
    )
    expect(page).to have_content(
      'Select whether you want to recruit the candidate with pending conditions',
    )
  end

  def when_i_select_no_and_click_continue
    choose('No')
    when_i_click_continue
  end

  def and_i_select_yes_and_click_continue
    choose('Yes')
    when_i_click_continue
  end

  def then_i_see_the_offer_page_without_a_flash_message
    expect(page).to have_current_path(provider_interface_application_choice_offer_path(application_choice_id: @application_choice.id))
    expect(page).to have_no_content('Applicant recruited with conditions pending')
  end

  def then_i_see_the_offer_page_with_a_flash_message
    expect(page).to have_current_path(provider_interface_application_choice_offer_path(application_choice_id: @application_choice.id))
    expect(page).to have_content('Applicant recruited with conditions pending')
  end

  def and_the_application_is_now_recruited
    expect(@application_choice.reload.recruited?).to be_truthy
  end

  def when_i_log_in_as_the_candidate
    logout
    login_as(@application_choice.candidate)
  end

  def then_i_see_the_offer_page_with_a_message_about_pending_ske_conditions
    visit candidate_interface_application_offer_dashboard_path
    expect(page).to have_content('Remember to complete your subject knowledge enhancement course to meet the conditions of this offer.')
  end

  def when_i_go_back_as_the_provider_and_open_application_choice
    visit provider_interface_application_choice_path(@application_choice)
  end

  def and_confirm_all_conditions_met_on_the_next_page
    click_link_or_button 'Mark conditions as met and tell candidate'
  end

  def then_i_see_application_is_recruited_with_all_conditions_met
    expect(page).to have_content('Recruited')
    expect(page).to have_no_content('SKE conditions pending')
  end
end

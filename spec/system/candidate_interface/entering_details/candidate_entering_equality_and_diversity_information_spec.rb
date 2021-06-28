require 'rails_helper'

RSpec.feature 'Entering their equality and diversity information' do
  include CandidateHelper

  scenario 'Candidate submits equality and diversity information' do
    given_i_am_signed_in
    and_i_have_completed_my_application_form
    and_i_submit_my_application
    then_i_see_the_equality_and_diversity_page

    when_i_choose_not_to_complete_equality_and_diversity
    then_i_can_submit_my_application

    when_i_am_on_the_equality_and_diversity_page
    and_i_can_see_a_link_to_the_privacy_policy
    and_i_choose_to_complete_equality_and_diversity
    then_i_am_asked_to_choose_my_sex

    when_i_try_and_submit_without_choosing_my_sex
    then_i_see_an_error_to_choose_my_sex

    when_i_choose_my_sex
    and_i_click_on_continue
    then_i_am_asked_if_i_have_a_disability

    when_i_try_and_submit_without_choosing_if_i_have_a_disability
    then_i_see_an_error_to_choose_if_i_have_a_disability

    when_i_choose_no_for_having_a_disability
    and_i_click_on_continue
    then_i_am_asked_for_my_ethnic_group

    when_i_try_and_submit_without_choosing_my_ethnic_group
    then_i_see_an_error_to_choose_my_ethnic_group

    when_i_choose_that_i_prefer_not_to_say_my_ethnic_group
    and_i_click_on_continue
    then_i_can_review_my_answers

    when_i_click_change_my_disability
    then_i_am_asked_if_i_have_a_disability

    when_i_choose_yes_for_having_a_disability
    and_i_click_on_continue
    then_i_see_the_disabilities_page

    when_i_try_and_submit_without_ticking_disabilities
    then_i_see_an_error_to_select_disabilties

    when_i_check_my_disabilities
    and_i_enter_another_disability
    and_i_click_on_continue
    then_i_can_review_my_disabilities

    when_i_click_change_sex
    then_i_am_asked_to_choose_my_sex

    when_i_choose_a_different_sex
    and_i_click_on_continue
    then_i_can_review_my_updated_sex

    when_i_click_change_my_disability
    and_i_choose_yes_for_having_a_disability
    and_i_click_on_continue
    then_i_see_the_disabilties_i_selected_are_checked

    when_i_change_my_disabilities
    and_i_click_on_continue
    then_i_can_review_my_updated_disabilities

    when_i_click_change_ethnic_group
    and_i_choose_another_ethnic_group
    and_i_click_on_continue
    then_i_am_asked_for_my_ethnic_background

    when_i_try_and_submit_without_choosing_my_ethnic_background
    then_i_see_an_error_to_choose_my_ethnic_background

    when_i_choose_my_ethnic_background
    and_i_describe_my_other_ethnic_background
    and_i_click_on_continue
    then_i_can_review_my_updated_ethnicity

    when_i_manually_restart_the_questionnaire
    then_i_go_straight_to_the_review_page

    when_i_click_change_ethnic_group
    when_i_choose_that_i_prefer_not_to_say_my_ethnic_group
    and_i_click_on_continue
    then_the_ethnicity_hesa_code_has_been_reset

    when_i_click_change_my_disability
    and_i_choose_that_i_prefer_not_to_state_my_disabilities
    and_i_click_on_continue
    then_the_disabilities_hesa_code_has_been_reset
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_have_completed_my_application_form
    candidate_completes_application_form
  end

  def and_i_submit_my_application
    click_link 'Check and submit your application'
    click_link t('continue')
  end

  def then_i_see_the_equality_and_diversity_page
    expect(page).to have_title 'Equality and diversity questionnaire'
    expect(page).to have_content 'Can you complete a 3-minute questionnaire?'
  end

  def when_i_choose_not_to_complete_equality_and_diversity
    choose 'No'
    click_button t('continue')
  end

  def then_i_can_submit_my_application
    expect(page).to have_content 'Send application'
  end

  def when_i_am_on_the_equality_and_diversity_page
    visit candidate_interface_start_equality_and_diversity_path
  end

  def and_i_can_see_a_link_to_the_privacy_policy
    expect(page).to have_link('Find out how we use and look after your data', href: candidate_interface_privacy_policy_path)
  end

  def and_i_choose_to_complete_equality_and_diversity
    click_button t('continue')
  end

  def then_i_am_asked_to_choose_my_sex
    expect(page).to have_content('What is your sex?')
  end

  def when_i_try_and_submit_without_choosing_my_sex
    click_button t('continue')
  end

  def then_i_see_an_error_to_choose_my_sex
    expect(page).to have_content('Choose your sex')
  end

  def when_i_choose_my_sex
    choose 'Male'
  end

  def and_i_click_on_continue
    click_button t('continue')
  end

  def then_i_can_review_my_answers
    expect(page).to have_content('Check your answers')
    expect(page).to have_content('Male')
    expect(page).to have_content('No')
    expect(page).to have_content('Prefer not to say')
  end

  def when_i_click_change_sex
    click_change_link('sex')
  end

  def when_i_choose_a_different_sex
    choose 'Female'
  end

  def then_i_can_review_my_updated_sex
    expect(page).to have_content('Check your answers')
    expect(page).to have_content('Female')
  end

  def then_i_am_asked_if_i_have_a_disability
    expect(page).to have_content('Are you disabled?')
  end

  def when_i_try_and_submit_without_choosing_if_i_have_a_disability
    click_button t('continue')
  end

  def then_i_see_an_error_to_choose_if_i_have_a_disability
    expect(page).to have_content('Choose if you have a disability')
  end

  def when_i_choose_no_for_having_a_disability
    choose 'No'
  end

  def then_i_am_asked_for_my_ethnic_group
    expect(page).to have_content('What is your ethnic group?')
  end

  def when_i_try_and_submit_without_choosing_my_ethnic_group
    click_button t('continue')
  end

  def then_i_see_an_error_to_choose_my_ethnic_group
    expect(page).to have_content('Choose your ethnic group')
  end

  def when_i_choose_that_i_prefer_not_to_say_my_ethnic_group
    choose 'Prefer not to say'
  end

  def when_i_click_change_my_disability
    click_change_link('disability')
  end

  def when_i_choose_yes_for_having_a_disability
    choose 'Yes'
  end

  def then_i_see_the_disabilities_page
    expect(page).to have_content('Please select all that apply to you')
  end

  def when_i_try_and_submit_without_ticking_disabilities
    click_button t('continue')
  end

  def then_i_see_an_error_to_select_disabilties
    expect(page).to have_content('Select all disabilities that apply to you')
  end

  def when_i_check_my_disabilities
    check 'Blind'
    check 'Deaf'
    check 'Other'
  end

  def and_i_enter_another_disability
    fill_in 'Describe your disability', with: 'other disability'
  end

  def then_i_can_review_my_disabilities
    expect(page).to have_content('Check your answers')
    expect(page).to have_content('Male')
    expect(page).to have_content('Yes (Blind, Deaf and other disability)')
  end

  def and_i_choose_yes_for_having_a_disability
    choose 'Yes'
  end

  def then_i_see_the_disabilties_i_selected_are_checked
    expect(first('input[type=checkbox][value=Blind]')).to be_checked
    expect(first('input[type=checkbox][value=Deaf]')).to be_checked
    expect(first('input[type=checkbox][value=Other]')).to be_checked
    expect(page).to have_selector("input[value='other disability']")
  end

  def when_i_change_my_disabilities
    uncheck 'Blind'
    uncheck 'Other'
  end

  def then_i_can_review_my_updated_disabilities
    expect(page).to have_content('Check your answers')
    expect(page).to have_content('Yes (Deaf)')
  end

  def when_i_click_change_ethnic_group
    click_change_link('ethnicity')
  end

  def and_i_choose_another_ethnic_group
    choose 'White'
  end

  def then_i_am_asked_for_my_ethnic_background
    expect(page).to have_content('Which of the following best describes your White background?')
  end

  def when_i_try_and_submit_without_choosing_my_ethnic_background
    click_button t('continue')
  end

  def then_i_see_an_error_to_choose_my_ethnic_background
    expect(page).to have_content('Choose your ethnic background')
  end

  def when_i_choose_my_ethnic_background
    choose 'Another White background'
  end

  def and_i_describe_my_other_ethnic_background
    fill_in 'Your White background', with: 'I am Hungarian'
  end

  def then_i_can_review_my_updated_ethnicity
    expect(page).to have_content('Check your answers')
    expect(page).to have_content('White (I am Hungarian)')
  end

  def when_i_manually_restart_the_questionnaire
    visit candidate_interface_start_equality_and_diversity_path
    click_button t('continue')
  end

  def then_i_go_straight_to_the_review_page
    expect(page).to have_current_path candidate_interface_review_equality_and_diversity_path
  end

  def then_the_ethnicity_hesa_code_has_been_reset
    expect(current_candidate.current_application.reload.equality_and_diversity['hesa_ethnicity']).to be_nil
  end

  def and_i_choose_that_i_prefer_not_to_state_my_disabilities
    choose 'Prefer not to say'
  end

  def then_the_disabilities_hesa_code_has_been_reset
    expect(current_candidate.current_application.reload.equality_and_diversity['hesa_disabilities']).to eq([])
  end
end

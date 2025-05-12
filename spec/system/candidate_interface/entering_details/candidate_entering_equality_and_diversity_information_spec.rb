require 'rails_helper'

RSpec.describe 'Entering their equality and diversity information' do
  include CandidateHelper

  scenario 'Candidate submits equality and diversity information' do
    given_i_am_signed_in
    and_i_visit_the_site
    and_i_click_on_the_equality_and_diversity_section
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

    then_i_am_asked_free_school_meal
    when_i_choose_that_i_didnt_receive_free_school_meal
    and_i_click_on_continue
    then_i_can_review_my_answers

    when_i_click_change_my_disability
    then_i_see_the_disabilities_page

    when_i_try_and_submit_without_ticking_disabilities
    then_i_see_an_error_to_choose_if_i_have_a_disability

    when_i_check_my_disabilities
    and_i_enter_another_disability
    and_i_click_on_continue
    then_i_can_review_my_disabilities

    when_i_click_change_sex
    then_i_am_asked_to_choose_my_sex

    when_i_choose_a_different_sex
    and_i_click_on_continue
    then_i_can_review_my_updated_sex

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

    when_i_click_change_ethnic_group
    when_i_choose_that_i_prefer_not_to_say_my_ethnic_group
    and_i_click_on_continue
    then_the_ethnicity_hesa_code_has_been_set
    then_the_ethnic_background_is_prefer_not_to_say

    when_i_click_change_my_disability
    and_i_choose_that_i_prefer_not_to_state_my_disabilities
    and_i_click_on_continue
    then_the_disabilities_hesa_code_has_been_reset
  end

  def given_i_am_signed_in
    given_i_am_signed_in_with_one_login
    @current_candidate.current_application.update!(first_nationality: 'British', date_of_birth: Time.zone.now)
  end

  def and_i_visit_the_site
    visit candidate_interface_details_path
  end

  def and_i_click_on_the_equality_and_diversity_section
    click_link_or_button 'Equality and diversity questions'
  end

  def when_i_click_continue
    click_link_or_button t('continue')
  end

  def then_i_can_submit_my_application
    expect(page).to have_content 'Send application'
  end

  def and_i_choose_to_complete_equality_and_diversity
    click_link_or_button t('continue')
  end

  def then_i_am_asked_to_choose_my_sex
    expect(page).to have_content('What is your sex?')
  end

  def then_i_am_asked_free_school_meal
    expect(page).to have_content('Free school meals')
  end

  def when_i_choose_that_i_didnt_receive_free_school_meal
    choose 'No'
  end

  def when_i_try_and_submit_without_choosing_my_sex
    click_link_or_button t('continue')
  end

  def then_i_see_an_error_to_choose_my_sex
    expect(page).to have_content('Select your sex or ‘Prefer not to say’')
  end

  def when_i_choose_my_sex
    choose 'Male'
  end

  def and_i_click_on_continue
    click_link_or_button t('continue')
  end

  def then_i_can_review_my_answers
    expect(page).to have_content('Check your answers')
    expect(page).to have_content('Male')
    expect(page).to have_content('I do not have any of these disabilities or health conditions')
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
    expect(page).to have_content('Do you have any of these disabilities or health conditions?')
  end

  def when_i_try_and_submit_without_choosing_if_i_have_a_disability
    click_link_or_button t('continue')
  end

  def then_i_see_an_error_to_choose_if_i_have_a_disability
    expect(page).to have_content('Select if you have any of these disabilities or health conditions')
  end

  def when_i_choose_no_for_having_a_disability
    check 'I do not have any of these disabilities or health conditions'
  end

  def then_i_am_asked_for_my_ethnic_group
    expect(page).to have_content('What is your ethnic group?')
  end

  def when_i_try_and_submit_without_choosing_my_ethnic_group
    click_link_or_button t('continue')
  end

  def then_i_see_an_error_to_choose_my_ethnic_group
    expect(page).to have_content('Select an ethnic group or ‘Prefer not to say’')
  end

  def when_i_choose_that_i_prefer_not_to_say_my_ethnic_group
    choose 'Prefer not to say'
  end

  def when_i_click_change_my_disability
    click_link_or_button 'Change disability'
  end

  def when_i_choose_yes_for_having_a_disability
    choose 'Yes'
  end

  def then_i_see_the_disabilities_page
    expect(page).to have_content('Disabilities and health conditions')
  end

  def when_i_try_and_submit_without_ticking_disabilities
    uncheck 'I do not have any of these disabilities or health conditions'
    click_link_or_button t('continue')
  end

  def when_i_check_my_disabilities
    check 'Blindness or a visual impairment not corrected by glasses'
    check 'Deafness or a serious hearing impairment'
    check 'Another disability, health condition or impairment affecting daily life'
  end

  def and_i_enter_another_disability
    fill_in 'Your disability or health condition (optional)', with: 'Acquired brain injury'
  end

  def then_i_can_review_my_disabilities
    expect(page).to have_content('Check your answers')
    expect(page).to have_content('Male')
    expect(page).to have_content('Blindness or a visual impairment not corrected by glassesDeafness or a serious hearing impairmentAcquired brain injury')
  end

  def and_i_choose_yes_for_having_a_disability
    choose 'Yes'
  end

  def when_i_change_my_disabilities
    click_link_or_button 'Change disability'
    uncheck 'Blindness or a visual impairment not corrected by glasses'
    uncheck 'Another disability, health condition or impairment affecting daily life'
  end

  def then_i_can_review_my_updated_disabilities
    expect(page).to have_content('Check your answers')
    expect(page).to have_content('Deafness or a serious hearing impairment')
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
    click_link_or_button t('continue')
  end

  def then_i_see_an_error_to_choose_my_ethnic_background
    expect(page).to have_content('Select your background or ‘Prefer not to say’')
  end

  def when_i_choose_my_ethnic_background
    choose 'Another White background'
  end

  def and_i_describe_my_other_ethnic_background
    fill_in 'Your White background', with: 'I am Hungarian'
  end

  def then_i_can_review_my_updated_ethnicity
    expect(page).to have_content('Check your answers')
    expect(page).to have_content('I am Hungarian')
  end

  def then_the_ethnicity_hesa_code_has_been_set
    expect(current_candidate.current_application.reload.equality_and_diversity['hesa_ethnicity']).to eq('998')
  end

  def then_the_ethnic_background_is_prefer_not_to_say
    expect(current_candidate.current_application.reload.equality_and_diversity['ethnic_background']).to eq('Prefer not to say')
  end

  def and_i_choose_that_i_prefer_not_to_state_my_disabilities
    uncheck 'Deafness or a serious hearing impairment'
    check 'Prefer not to say'
  end

  def then_the_disabilities_hesa_code_has_been_reset
    expect(current_candidate.current_application.reload.equality_and_diversity['hesa_disabilities']).to eq(['98'])
  end
end

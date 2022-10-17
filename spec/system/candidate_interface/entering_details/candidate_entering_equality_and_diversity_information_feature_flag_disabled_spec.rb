require 'rails_helper'

RSpec.feature 'Entering their equality and diversity information' do
  include CandidateHelper

  scenario 'Candidate submits equality and diversity information' do
    given_the_new_reference_flow_feature_flag_is_on
    given_i_am_signed_in
    and_i_have_completed_my_application_form
    and_i_submit_my_application
    then_i_see_the_equality_and_diversity_page

    when_i_am_on_the_equality_and_diversity_page
    and_i_can_see_a_link_to_the_privacy_policy

    when_i_click_continue
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
    then_the_ethnicity_hesa_code_has_been_reset

    when_i_click_change_my_disability
    and_i_choose_that_i_prefer_not_to_state_my_disabilities
    and_i_click_on_continue
    then_the_disabilities_hesa_code_has_been_reset
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def given_the_new_reference_flow_feature_flag_is_on
    FeatureFlag.activate(:new_references_flow)
  end

  def and_i_have_completed_my_application_form
    candidate_completes_application_form(with_referees: false)
    and_candidate_completes_new_references_section
  end

  def and_candidate_completes_new_references_section
    click_link 'References to be requested if you accept an offer'
    and_the_candidate_add_a_reference(
      type: 'Academic, such as a university tutor',
      name: 'John Doe',
      email: 'johndoe@example.com',
      relationship: 'He is my singing teacher',
    )
    and_the_candidate_add_a_reference(
      type: 'Academic, such as a university tutor',
      name: 'Voldemort',
      email: 'voldemort@example.com',
      relationship: 'We ran into wrong wall at train station',
    )
    choose 'Yes, I have completed this section'
    click_button 'Continue'
  end

  def and_i_submit_my_application
    click_link 'Check and submit your application'
    click_link t('continue')
  end

  def then_i_see_the_equality_and_diversity_page
    expect(page).to have_title 'Equality and diversity questions'
  end

  def when_i_click_continue
    click_link t('continue')
  end

  def then_i_can_submit_my_application
    expect(page).to have_content 'Send application'
  end

  def when_i_am_on_the_equality_and_diversity_page
    visit candidate_interface_start_equality_and_diversity_path
  end

  def and_i_can_see_a_link_to_the_privacy_policy
    expect(page).to have_link('Privacy policy', href: candidate_interface_privacy_policy_path)
  end

  def and_i_choose_to_complete_equality_and_diversity
    click_button t('continue')
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
    click_button t('continue')
  end

  def then_i_see_an_error_to_choose_my_sex
    expect(page).to have_content('Select your sex or ‘Prefer not to say’')
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
    expect(page).to have_content('Do you have any of these disabilities or health conditions?')
  end

  def when_i_try_and_submit_without_choosing_if_i_have_a_disability
    click_button t('continue')
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
    click_button t('continue')
  end

  def then_i_see_an_error_to_choose_my_ethnic_group
    expect(page).to have_content('Select an ethnic group or ‘Prefer not to say’')
  end

  def when_i_choose_that_i_prefer_not_to_say_my_ethnic_group
    choose 'Prefer not to say'
  end

  def when_i_click_change_my_disability
    click_link 'Change disability'
  end

  def when_i_choose_yes_for_having_a_disability
    choose 'Yes'
  end

  def then_i_see_the_disabilities_page
    expect(page).to have_content('Disabilities and health conditions')
  end

  def when_i_try_and_submit_without_ticking_disabilities
    uncheck 'I do not have any of these disabilities or health conditions'
    click_button t('continue')
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
    click_link 'Change disability'
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
    click_button t('continue')
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

  def then_the_ethnicity_hesa_code_has_been_reset
    expect(current_candidate.current_application.reload.equality_and_diversity['hesa_ethnicity']).to be_nil
  end

  def and_i_choose_that_i_prefer_not_to_state_my_disabilities
    uncheck 'Deafness or a serious hearing impairment'
    check 'Prefer not to say'
  end

  def then_the_disabilities_hesa_code_has_been_reset
    expect(current_candidate.current_application.reload.equality_and_diversity['hesa_disabilities']).to eq(['98'])
  end
end

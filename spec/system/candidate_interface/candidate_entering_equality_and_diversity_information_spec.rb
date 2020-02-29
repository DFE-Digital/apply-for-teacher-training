require 'rails_helper'

RSpec.feature 'Entering their equality and diversity information' do
  include CandidateHelper

  scenario 'Candidate submits equality and diversity information' do
    given_i_am_signed_in
    and_the_equality_and_diversity_feature_flag_is_active
    and_i_have_an_application_form_that_is_ready_to_submit
    and_i_am_on_the_review_page

    when_i_click_on_continue
    then_i_see_the_equality_and_diversity_page

    when_i_choose_not_to_complete_equality_and_diversity
    then_i_can_submit_my_application

    when_i_am_on_the_equality_and_diversity_page
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
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_the_equality_and_diversity_feature_flag_is_active
    FeatureFlag.activate('equality_and_diversity')
  end

  def and_i_have_an_application_form_that_is_ready_to_submit
    @application = create(
      :completed_application_form,
      :with_completed_references,
      candidate: @current_candidate,
      submitted_at: nil,
      references_count: 2,
      with_gces: true,
    )
  end

  def and_i_am_on_the_review_page
    visit candidate_interface_application_review_path
  end

  def when_i_click_on_continue
    click_link 'Continue'
  end

  def then_i_see_the_equality_and_diversity_page
    expect(page).to have_content('Equality and diversity')
  end

  def when_i_choose_not_to_complete_equality_and_diversity
    click_link 'Continue without completing questionnaire'
  end

  def then_i_can_submit_my_application
    expect(page).to have_content('Submit application')
  end

  def when_i_am_on_the_equality_and_diversity_page
    visit candidate_interface_start_equality_and_diversity_path
  end

  def and_i_choose_to_complete_equality_and_diversity
    click_link 'Continue'
  end

  def then_i_am_asked_to_choose_my_sex
    expect(page).to have_content('What is your sex?')
  end

  def when_i_try_and_submit_without_choosing_my_sex
    click_button 'Continue'
  end

  def then_i_see_an_error_to_choose_my_sex
    expect(page).to have_content('Choose your sex')
  end

  def when_i_choose_my_sex
    choose 'Male'
  end

  def and_i_click_on_continue
    click_button 'Continue'
  end

  def then_i_can_review_my_answers
    expect(page).to have_content('Check your answers')
    expect(page).to have_content('Male')
    expect(page).to have_content('No')
    expect(page).to have_content('Prefer not to say')
  end

  def when_i_click_change_sex
    click_link 'Change sex'
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
    click_button 'Continue'
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
    click_button 'Continue'
  end

  def then_i_see_an_error_to_choose_my_ethnic_group
    expect(page).to have_content('Choose your ethnic group')
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
    expect(page).to have_content('Please select all that apply to you')
  end

  def when_i_try_and_submit_without_ticking_disabilities
    click_button 'Continue'
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
    click_link 'Change ethnicity'
  end

  def and_i_choose_another_ethnic_group
    choose 'White'
  end

  def then_i_am_asked_for_my_ethnic_background
    expect(page).to have_content('Which of the following best describes your White background?')
  end

  def when_i_try_and_submit_without_choosing_my_ethnic_background
    click_button 'Continue'
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
end

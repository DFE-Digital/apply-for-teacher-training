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
    then_i_can_review_my_answer

    when_i_click_change_sex
    then_i_am_asked_to_choose_my_sex

    when_i_choose_a_different_sex
    and_i_click_on_continue
    then_i_can_review_my_updated_sex
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

  def then_i_can_review_my_answer
    expect(page).to have_content('Check your answers')
    expect(page).to have_content('Male')
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
end

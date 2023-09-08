require 'rails_helper'

RSpec.feature 'Candidate is redirected correctly', continuous_applications: false do
  include CandidateHelper

  it 'Candidate reviews application and completes equality and diversity' do
    given_i_am_signed_in
    and_i_review_my_application
    then_i_should_see_that_i_need_to_complete_the_equality_and_diversity_section

    when_i_click_on_complete_your_equality_and_diversity_questions
    then_i_should_be_redirected_to_the_sex_page

    when_i_complete_the_equality_and_diversity_questions
    and_i_review_my_application
    then_i_should_see_that_i_need_to_complete_the_equality_and_diversity_section

    when_i_click_on_complete_your_equality_and_diversity_questions
    then_i_should_be_redirected_to_the_review_page
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_review_my_application
    and_i_visit_the_application_form_page
    when_i_click_on_check_your_answers
  end

  def then_i_should_see_that_i_need_to_complete_the_equality_and_diversity_section
    expect(page).to have_selector("a[data-qa='incomplete-equality_and_diversity']")
  end

  def when_i_click_on_complete_your_equality_and_diversity_questions
    click_link 'Complete your equality and diversity questions'
  end

  def then_i_should_be_redirected_to_the_sex_page
    expect(page).to have_current_path(candidate_interface_edit_equality_and_diversity_sex_path)
  end

  def when_i_complete_the_equality_and_diversity_questions
    candidate_fills_in_diversity_information(school_meals: false, complete_section: false)
  end

  def then_i_should_be_redirected_to_the_review_page
    expect(page).to have_current_path(candidate_interface_review_equality_and_diversity_path)
  end

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_check_your_answers
    click_link 'Check and submit your application'
  end

  def then_i_should_be_redirected_to_the_application_review_page
    expect(page).to have_current_path(candidate_interface_application_review_path)
  end
end

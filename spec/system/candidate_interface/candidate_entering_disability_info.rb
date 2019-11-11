require 'rails_helper'

RSpec.feature 'Entering their disability information' do
  include CandidateHelper

  scenario 'Candidate submits their disability information' do
    given_i_am_not_signed_in
    and_i_visit_the_training_with_a_disability_page
    then_i_should_see_the_homepage

    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_training_with_a_disability
    and_i_fill_in_my_disability_information
    and_i_submit_the_form
    then_i_can_check_my_answers

    when_i_click_to_change_my_answer
    and_i_select_no
    and_i_submit_the_form
    then_i_can_check_my_revised_answers

    when_i_submit_my_details
    then_i_should_see_the_form
    and_that_the_section_is_completed

    when_i_click_on_training_with_a_disability
    then_i_can_check_my_revised_answers
  end

  def given_i_am_not_signed_in; end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_visit_the_training_with_a_disability_page
    visit candidate_interface_training_with_a_disability_edit_path
  end

  def then_i_should_see_the_homepage
    expect(page).to have_current_path(candidate_interface_start_path)
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_training_with_a_disability
    click_link t('page_titles.training_with_a_disability')
  end

  def and_i_fill_in_my_disability_information
    scope = 'application_form.training_with_a_disability'
    choose t('disclose_disability.yes', scope: scope)
    fill_in t('disability_disclosure.label', scope: scope), with: 'I have difficulty climbing stairs'
  end

  def and_i_submit_the_form
    click_button t('application_form.training_with_a_disability.complete_form_button')
  end

  def then_i_can_check_my_answers
    expect(page).to have_content 'Yes'
    expect(page).to have_content 'I have difficulty climbing stairs'
  end

  def when_i_click_to_change_my_answer
    first('.govuk-summary-list__actions').click_link 'Change'
  end

  def and_i_select_no
    scope = 'application_form.training_with_a_disability'
    choose t('disclose_disability.no', scope: scope)
  end

  def then_i_can_check_my_revised_answers
    expect(page).to have_content 'No'
    expect(page).not_to have_content 'I have difficulty climbing stairs'
  end

  def when_i_submit_my_details
    click_link 'Continue'
  end

  def then_i_should_see_the_form
    expect(page).to have_content(t('page_titles.training_with_a_disability'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#training-with-a-disability-completed', text: 'Completed')
  end
end

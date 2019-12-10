require 'rails_helper'

RSpec.feature 'Entering their disability information' do
  include CandidateHelper

  scenario 'Candidate submits their disability information' do
    given_i_am_signed_in
    and_i_visit_the_site
    and_the_training_with_a_disability_feature_flag_is_off
    then_i_dont_see_training_with_a_disability

    when_i_click_on_check_your_answers
    then_i_dont_see_training_with_a_disability_is_missing_below_the_section

    when_i_submit_my_application
    then_i_dont_see_a_training_with_a_disability_validation_error

    when_i_visit_training_with_a_disability_section
    then_i_see_the_application_form

    given_training_with_a_disability_feature_flag_is_on
    and_i_visit_the_site

    when_i_click_on_check_your_answers
    then_i_see_training_with_a_disability_is_missing_below_the_section

    when_i_submit_my_application
    then_i_see_a_training_with_a_disability_validation_error

    when_i_visit_the_site
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

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def and_the_training_with_a_disability_feature_flag_is_off
    FeatureFlag.deactivate('training_with_a_disability')
  end

  def then_i_dont_see_training_with_a_disability
    expect(page).not_to have_content(t('page_titles.training_with_a_disability'))
  end

  def when_i_click_on_check_your_answers
    click_link 'Check your answers before submitting'
  end

  def then_i_dont_see_training_with_a_disability_is_missing_below_the_section
    expect(page).not_to have_content(t('review_application.training_with_a_disability.incomplete'))
  end

  def when_i_submit_my_application
    click_link 'Continue'
  end

  def then_i_dont_see_a_training_with_a_disability_validation_error
    within('.govuk-error-summary') do
      expect(page).not_to have_content(t('review_application.training_with_a_disability.incomplete'))
    end
  end

  def when_i_visit_training_with_a_disability_section
    visit candidate_interface_training_with_a_disability_show_path
  end

  def then_i_see_the_application_form
    expect(page).to have_content(t('page_titles.application_form'))
  end

  def given_training_with_a_disability_feature_flag_is_on
    FeatureFlag.activate('training_with_a_disability')
  end

  def then_i_see_training_with_a_disability_is_missing_below_the_section
    within('#missing-training_with_a_disability-error') do
      expect(page).to have_content(t('review_application.training_with_a_disability.incomplete'))
    end
  end

  def then_i_see_a_training_with_a_disability_validation_error
    within('.govuk-error-summary') do
      expect(page).to have_content(t('review_application.training_with_a_disability.incomplete'))
    end
  end

  def when_i_visit_the_site
    and_i_visit_the_site
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
    expect(page).to have_css('#training-with-a-disability-badge-id', text: 'Completed')
  end
end

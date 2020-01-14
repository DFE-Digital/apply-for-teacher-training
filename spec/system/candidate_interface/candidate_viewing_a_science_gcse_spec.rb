require 'rails_helper'

RSpec.feature 'Candidate viewing Science GCSE' do
  include CandidateHelper

  scenario 'Candidate views a Science GCSE only when a primary course is chosen' do
    given_i_am_signed_in
    when_i_visit_the_site
    then_i_dont_see_science_gcse

    when_i_click_on_check_your_answers
    then_i_dont_see_science_gcse_is_missing_below_the_section

    when_i_submit_my_application
    then_i_dont_see_a_science_gcse_validation_error

    given_courses_exist
    and_i_am_on_your_application_page
    when_i_add_a_primary_course
    then_i_see_science_gcse

    when_i_click_on_check_your_answers
    then_i_see_science_gcse_is_missing_below_the_section

    when_i_submit_my_application
    then_i_see_a_science_gcse_validation_error
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def then_i_see_science_gcse
    expect(page).to have_content('Science GCSE or equivalent')
  end

  def when_i_click_on_check_your_answers
    click_link 'Check your answers before submitting'
  end

  def then_i_see_science_gcse_is_missing_below_the_section
    within('#missing-science_gcse-error') do
      expect(page).to have_content(t('review_application.science_gcse.incomplete'))
    end
  end

  def then_i_dont_see_science_gcse
    expect(page).not_to have_content('Science GCSE or equivalent')
  end

  def then_i_dont_see_science_gcse_is_missing_below_the_section
    expect(page).not_to have_content(t('review_application.science_gcse.incomplete'))
  end

  def when_i_submit_my_application
    click_link 'Continue'
  end

  def then_i_dont_see_a_science_gcse_validation_error
    within('.govuk-error-summary') do
      expect(page).not_to have_content(t('review_application.science_gcse.incomplete'))
    end
  end

  def and_i_am_on_your_application_page
    visit candidate_interface_application_form_path
  end

  def when_i_add_a_primary_course
    click_link 'Course choices'
    candidate_fills_in_course_choices
  end

  def then_i_see_science_gcse_is_missing_below_the_section
    within '#missing-science_gcse-error' do
      expect(page).to have_content(t('review_application.science_gcse.incomplete'))
    end
  end

  def then_i_see_a_science_gcse_validation_error
    within('.govuk-error-summary') do
      expect(page).to have_content(t('review_application.science_gcse.incomplete'))
    end
  end
end

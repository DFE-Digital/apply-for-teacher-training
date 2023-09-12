require 'rails_helper'

RSpec.feature 'Candidate viewing Science GCSE', continuous_applications: false do
  include CandidateHelper

  it 'Candidate views a Science GCSE only when a primary course is chosen' do
    given_i_am_signed_in
    when_i_visit_the_site
    then_i_dont_see_science_gcse

    when_i_click_on_check_your_answers
    then_i_dont_see_science_gcse_is_incomplete_below_the_section

    when_i_submit_my_application
    then_i_dont_see_a_science_gcse_validation_error

    given_courses_exist
    and_i_am_on_your_application_page
    when_i_add_a_primary_course
    then_i_see_science_gcse

    when_i_click_on_check_your_answers
    then_i_see_science_gcse_is_incomplete_below_the_section

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
    click_link 'Check and submit your application'
  end

  def then_i_see_science_gcse_is_incomplete_below_the_section
    within('#incomplete-science_gcse-error') do
      expect(page).to have_content(t('review_application.science_gcse.incomplete'))
    end
  end

  def then_i_dont_see_science_gcse
    expect(page).not_to have_content('Science GCSE or equivalent')
  end

  def then_i_dont_see_science_gcse_is_incomplete_below_the_section
    expect(page).not_to have_content(t('review_application.science_gcse.incomplete'))
  end

  def when_i_submit_my_application
    click_link t('continue')
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
    click_link 'Choose your courses'
    candidate_fills_in_apply_again_course_choice
  end

  def then_i_see_science_gcse_is_incomplete_below_the_section
    within '#incomplete-science_gcse-error' do
      expect(page).to have_content(t('review_application.science_gcse.incomplete'))
    end
  end

  def then_i_see_a_science_gcse_validation_error
    within('.govuk-error-summary') do
      expect(page).to have_content(t('review_application.science_gcse.incomplete'))
    end
  end
end

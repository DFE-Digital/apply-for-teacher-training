require 'rails_helper'

RSpec.feature 'Candidate entering GCSE English details' do
  include CandidateHelper

  scenario 'Candidate submits their GCSE English qualification' do
    given_i_am_signed_in
    and_i_wish_to_apply_to_a_course_that_requires_gcse_english
    and_i_visit_the_site

    and_i_click_on_the_english_gcse_link
    then_i_see_the_add_gcse_english_page

    when_i_select_gcse_option
    and_i_click_save_and_continue
    then_i_see_the_english_gcse_grade_page

    and_i_click_save_and_continue
    then_i_see_the_gcses_blank_error

    when_i_click_english_single_award
    and_i_click_save_and_continue
    then_i_see_the_enter_your_english_single_award_grade_error

    when_i_click_english_single_award
    and_i_enter_an_invalid_grade
    and_i_click_save_and_continue
    then_i_see_the_invalid_english_single_award_grade_error

    when_i_click_other_english_subject
    and_i_uncheck_english_single_award
    and_i_click_save_and_continue
    then_i_see_the_enter_an_english_gcse_error
    then_i_see_the_enter_your_other_english_grade_error

    when_i_click_other_english_subject
    and_i_enter_a_valid_english_gcse
    and_i_enter_a_valid_other_english_grade
    and_i_click_save_and_continue
    then_i_see_the_grade_year_page

    when_i_fill_in_the_award_year
    and_i_click_save_and_continue
    then_i_see_the_check_answers_page

    when_i_click_to_change_my_grades
    then_i_see_the_grades_i_entered_in_the_form

    when_i_enter_a_new_grade
    then_i_see_my_new_grade_on_the_review_page
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_wish_to_apply_to_a_course_that_requires_gcse_english
    course = create(:course, exposed_in_find: true, open_on_apply: true, name: 'English')
    course_option = create(:course_option, course: course)
    current_candidate.current_application.application_choices << create(:application_choice, course_option: course_option)
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def and_i_click_on_the_english_gcse_link
    click_on 'English GCSE or equivalent'
  end

  def then_i_see_the_add_gcse_english_page
    expect(page).to have_content 'Add English GCSE grade 4 (C) or above, or equivalent'
  end

  def when_i_select_gcse_option
    choose('GCSE')
  end

  def and_i_click_save_and_continue
    click_button t('save_and_continue')
  end

  def then_i_see_the_english_gcse_grade_page
    expect(page).to have_content t('multiple_gcse_edit_grade.page_title', subject: 'english')
    expect(page).to have_content t('multiple_gcse_edit_grade.page_title', subject: 'english')
  end

  def then_i_see_the_gcses_blank_error
    expect(page).to have_content 'Select at least one GCSE'
  end

  def when_i_click_english_single_award
    check 'English (Single award)'
  end

  def then_i_see_the_enter_your_english_single_award_grade_error
    expect(page).to have_content 'Enter your English (Single award) grade'
  end

  def then_i_see_the_enter_your_other_english_grade_error
    expect(page).to have_content 'Enter your other English subject grade'
  end

  def and_i_enter_an_invalid_grade
    within find('#candidate-interface-english-gcse-grade-form-english-gcses-english-single-award-conditional') do
      fill_in('Grade', with: 'AWESOME')
    end
  end

  def then_i_see_the_invalid_english_single_award_grade_error
    expect(page).to have_content 'Enter a real English (Single award) grade'
  end

  def and_i_uncheck_english_single_award
    uncheck 'English (Single award)'
  end

  def when_i_click_other_english_subject
    check 'Other English subject'
  end

  def then_i_see_the_enter_an_english_gcse_error
    expect(page).to have_content 'Enter an English GCSE'
  end

  def and_i_enter_a_valid_english_gcse
    within find('#candidate-interface-english-gcse-grade-form-english-gcses-other-english-gcse-conditional') do
      fill_in('What English GCSE do you have?', with: 'Cockney rhyming slang')
    end
  end

  def and_i_enter_a_valid_other_english_grade
    within find('#candidate-interface-english-gcse-grade-form-english-gcses-other-english-gcse-conditional') do
      fill_in('Grade', with: 'A*')
    end
  end

  def then_i_see_the_grade_year_page
    expect(page).to have_content t('gcse_edit_year.page_title', subject: 'English', qualification_type: 'GCSE')
  end

  def when_i_fill_in_the_award_year
    fill_in('Enter year', with: '2010')
  end

  def then_i_see_the_check_answers_page
    expect(page).to have_content('A* (Cockney Rhyming Slang)')
    expect(page).to have_content('Change grade for GCSE')
  end

  def when_i_click_to_change_my_grades
    click_on 'Change grade for GCSE'
  end

  def then_i_see_the_grades_i_entered_in_the_form
    expect(page).to have_selector("input[value='A*']")
    expect(page).to have_selector("input[value='Cockney rhyming slang']")
  end

  def when_i_enter_a_new_grade
    within find('#candidate-interface-english-gcse-grade-form-english-gcses-other-english-gcse-conditional') do
      fill_in('Grade', with: 'B')
    end
    and_i_click_save_and_continue
  end

  def then_i_see_my_new_grade_on_the_review_page
    expect(page).to have_content('B (Cockney Rhyming Slang)')
  end
end

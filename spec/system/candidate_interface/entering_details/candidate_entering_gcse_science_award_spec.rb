require 'rails_helper'

RSpec.describe 'Candidate entering GCSE Science details' do
  include CandidateHelper

  scenario 'Candidate submits their Science GCSE award' do
    given_i_am_signed_in_with_one_login
    and_i_wish_to_apply_to_a_course_that_requires_gcse_science
    and_i_visit_the_site

    and_i_click_on_the_science_gcse_link
    then_i_see_the_add_gcse_science_page

    when_i_select_gcse_option
    and_i_click_save_and_continue
    then_i_see_the_multiple_science_gcses_grade_page

    when_i_visit_the_review_page
    and_i_click_enter_your_grade
    and_i_click_back
    and_i_click_enter_your_grade

    # enter single award
    and_i_select_single_award
    and_i_click_save_and_continue
    then_i_see_the_grade_blank_error

    and_i_enter_an_invalid_grade
    and_i_click_save_and_continue
    then_i_see_the_grade_invalid_error

    then_i_enter_a_valid_grade
    and_i_click_save_and_continue
    then_i_see_the_grade_year_page
  end

  def when_i_visit_the_review_page
    visit candidate_interface_gcse_review_path(subject: 'science')
  end

  def and_i_click_enter_your_grade
    click_link_or_button 'Enter your grade'
  end

  def and_i_click_back
    click_link_or_button 'Back'
  end

  def and_i_wish_to_apply_to_a_course_that_requires_gcse_science
    course = create(:course, :open, name: 'Science')
    course_option = create(:course_option, course:)
    current_candidate.current_application.application_choices << create(:application_choice, course_option:)
  end

  def and_i_click_on_the_science_gcse_link
    click_link_or_button 'Science GCSE or equivalent'
  end

  def then_i_see_the_add_gcse_science_page
    expect(page).to have_content 'What type of qualification in science do you have?'
  end

  def when_i_select_gcse_option
    choose('GCSE')
  end

  def and_i_click_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def and_i_visit_the_site
    visit candidate_interface_details_path
  end

  def then_i_see_the_multiple_science_gcses_grade_page
    expect(page).to have_content t('gcse_edit_grade.page_title', subject: 'science', qualification_type: 'GCSE')
    expect(page).to have_content 'Select the GCSE you did and include your grade'
  end

  def and_i_select_single_award
    choose('Single award')
  end

  def then_i_see_the_grade_blank_error
    expect(page).to have_content 'Enter your single award grade'
  end

  def and_i_enter_an_invalid_grade
    within '#candidate-interface-science-gcse-grade-form-gcse-science-science-single-award-conditional' do
      fill_in('Grade', with: 'SHIZZ')
    end
  end

  def then_i_see_the_grade_invalid_error
    expect(page).to have_content('Enter a real single award grade')
  end

  def then_i_enter_a_valid_grade
    within '#candidate-interface-science-gcse-grade-form-gcse-science-science-single-award-conditional' do
      fill_in('Grade', with: 'A')
    end
  end

  def then_i_see_the_grade_year_page
    expect(page).to have_content t('gcse_edit_year.page_title', subject: 'science', qualification_type: 'GCSE')
  end

  def then_i_enter_a_valid_grade
    within '#candidate-interface-science-gcse-grade-form-gcse-science-science-single-award-conditional' do
      fill_in('Grade', with: 'A')
    end
  end
end

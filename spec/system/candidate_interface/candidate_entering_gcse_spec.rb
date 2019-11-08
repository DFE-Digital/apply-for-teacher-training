require 'rails_helper'

RSpec.feature 'Candidate entering GCSE details' do
  include CandidateHelper

  scenario 'Candidate submits their maths GCSE details' do
    given_i_am_signed_in
    and_i_visit_the_candidate_application_page
    and_i_click_on_the_maths_gcse_link
    then_i_see_the_add_gcse_maths_page

    when_i_select_gcse_option
    and_i_click_save_and_continue
    then_i_see_add_grade_and_year_page

    when_i_fill_in_grade_and_year
    and_i_click_save_and_continue

    then_i_see_the_review_for_maths_gcse
    and_i_see_correct_grade_and_awarded_year
  end

  scenario 'Candidate does not provide a qualification level' do
    given_i_am_signed_in
    and_i_visit_the_candidate_application_page
    and_i_click_on_the_maths_gcse_link

    then_i_see_the_add_gcse_maths_page

    and_i_do_not_select_any_gcse_option

    and_i_click_save_and_continue

    then_i_see_the_qualification_type_error
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def given_i_am_not_signed_in; end

  def and_i_click_on_the_maths_gcse_link
    click_on 'Maths GCSE or equivalent'
  end

  def and_i_click_on_the_english_gcse_link
    click_on 'English GCSE or equivalent'
  end

  def when_i_select_gcse_option
    choose('GCSE')
  end

  def and_i_click_save_and_continue
    click_button 'Save and continue'
  end

  def and_i_do_not_select_any_gcse_option; end

  def then_i_see_the_review_for_maths_gcse
    expect(page).to have_content 'Maths GCSE or equivalent'
  end

  def then_i_see_the_review_for_english_gcse
    expect(page).to have_content 'English GCSE or equivalent'
  end

  def and_i_visit_the_candidate_application_page
    visit '/candidate/application'
  end

  def then_i_see_the_add_gcse_maths_page
    expect(page).to have_content 'Add maths GCSE grade 4 (C) or above, or equivalent'
  end

  def then_i_see_the_add_gcse_english_page
    expect(page).to have_content 'Add English GCSE grade 4 (C) or above, or equivalent'
  end

  def then_i_see_the_edit_details_page
    expect(page).to have_content t('gcse_edit_details.heading.maths')
  end

  def and_i_see_correct_grade_and_awarded_year
    expect(page).to have_content 'AB'
    expect(page).to have_content '1990'
  end

  def then_i_see_add_grade_and_year_page
    expect(page).to have_content 'Maths qualification grade and year'
  end

  def when_i_fill_in_grade_and_year
    fill_in 'Enter your qualification grade', with: 'AB'
    fill_in 'Enter the year you gained your qualification', with: '1990'
  end

  def then_i_see_the_qualification_type_error
    expect(page).to have_content 'Enter the type of qualification'
  end
end

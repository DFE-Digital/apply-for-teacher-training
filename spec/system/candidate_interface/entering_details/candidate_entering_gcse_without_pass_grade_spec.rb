require 'rails_helper'

RSpec.feature 'Candidate entering GCSE details but without a pass grade' do
  include CandidateHelper

  scenario 'Candidate submits their maths GCSE details' do
    given_i_am_signed_in

    when_i_visit_the_candidate_application_page
    and_i_click_on_the_maths_gcse_link
    then_i_see_the_add_gcse_maths_page

    when_i_select_gcse_option
    and_i_click_save_and_continue
    then_i_see_add_grade_page

    when_i_fill_in_the_fail_grade
    and_i_click_save_and_continue
    then_i_am_prompted_to_explain_how_i_can_improve_this_grade

    when_i_fill_in_the_explanation
    and_i_click_save_and_continue
    and_i_fill_in_the_year
    and_i_click_save_and_continue
    then_i_see_the_review_page_with_correct_details

    # TODO: change grade
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_click_on_the_maths_gcse_link
    click_on 'Maths GCSE or equivalent'
  end

  def when_i_select_gcse_option
    choose('GCSE')
  end

  def and_i_select_gcse_option
    when_i_select_gcse_option
  end

  def and_i_click_save_and_continue
    click_button t('save_and_continue')
  end

  def when_i_visit_the_candidate_application_page
    visit '/candidate/application'
  end

  def then_i_see_the_add_gcse_maths_page
    expect(page).to have_content 'Add maths GCSE grade 4 (C) or above, or equivalent'
  end

  def then_i_see_the_review_page_with_correct_details
    expect(page).to have_content 'Maths GCSE or equivalent'

    expect(page).to have_content 'GCSE'
    expect(page).to have_content 'D'
    expect(page).to have_content 'Hard work and dedication'
    expect(page).to have_content '1990'
  end

  def then_i_see_add_grade_page
    expect(page).to have_content t('gcse_edit_grade.page_title', subject: 'maths', qualification_type: 'GCSE')
  end

  def when_i_fill_in_the_fail_grade
    fill_in 'Please specify your grade', with: 'D'
  end

  def then_i_am_prompted_to_explain_how_i_can_improve_this_grade
    expect(page).to have_content 'You need a maths GCSE at grade 4 (C) or above, or equivalent'
    expect(page).to have_content 'If you are working towards this qualification at grade 4 (C) or above, give us details (optional)'
  end

  def when_i_fill_in_the_explanation
    fill_in 'If you are working towards this qualification at grade 4 (C) or above, give us details (optional)', with: 'Hard work and dedication'
  end

  def and_i_fill_in_the_year
    fill_in 'Enter year', with: '1990'
  end
end

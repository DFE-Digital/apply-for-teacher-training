require 'rails_helper'

RSpec.describe 'Candidate changing their GCSE type' do
  include CandidateHelper

  scenario 'Candidate completes their maths GCSE and then changes the type to missing and then back to a GCSE' do
    given_i_am_signed_in_with_one_login
    and_i_click_on_the_maths_gcse_link
    then_i_see_the_add_gcse_maths_page

    when_i_select_gcse_option
    and_i_click_save_and_continue
    then_i_see_add_grade_page

    when_i_fill_in_the_grade
    and_i_click_save_and_continue
    then_i_see_add_year_page

    when_i_fill_in_the_year
    and_i_click_save_and_continue
    then_i_see_the_review_page_with_correct_details

    when_i_change_my_qualification_type
    and_i_select_i_do_not_have_a_gcse_in_maths_option
    and_i_click_save_and_continue
    then_i_see_the_review_page_with_updated_details

    when_i_change_my_qualification_type
    when_i_select_gcse_option
    and_i_click_save_and_continue
    then_i_see_add_grade_page
  end

  def when_i_visit_the_candidate_application_page
    visit root_path
  end

  def and_i_click_on_the_maths_gcse_link
    click_link_or_button 'Maths GCSE or equivalent'
  end

  def then_i_see_the_add_gcse_maths_page
    expect(page).to have_content 'What type of qualification in maths do you have?'
  end

  def when_i_select_gcse_option
    choose('GCSE')
  end

  def and_i_click_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def then_i_see_add_grade_page
    expect(page).to have_content t('gcse_edit_grade.page_title', subject: 'maths', qualification_type: 'GCSE')
  end

  def when_i_fill_in_the_grade
    fill_in 'Grade', with: 'A'
  end

  def then_i_see_add_year_page
    expect(page).to have_content t('gcse_edit_year.page_title', subject: 'maths', qualification_type: 'GCSE')
  end

  def when_i_fill_in_the_year
    fill_in 'Year', with: '1990'
  end

  def then_i_see_the_review_page_with_correct_details
    expect(page).to have_content 'Maths GCSE or equivalent'

    within('.app-summary-card__body') do
      expect(page).to have_content 'GCSE'
      expect(page).to have_content 'A'
      expect(page).to have_content '1990'
    end
  end

  def when_i_change_my_qualification_type
    find_link('Change', href: candidate_interface_gcse_details_edit_type_path(subject: 'maths')).click
  end

  def and_i_select_i_do_not_have_a_gcse_in_maths_option
    choose 'I do not have a qualification in maths yet'
  end

  def then_i_see_the_review_page_with_updated_details
    within('.app-summary-card__body') do
      expect(page).to have_content 'What type of maths qualification do you have?'
      expect(page).to have_content 'I don’t have a maths qualification yet'
      expect(page).to have_content 'Are you currently studying for this qualification?'
      expect(page).to have_content 'No'
      expect(page).to have_content 'Other evidence I have the skills required (optional)'
      expect(page).to have_content 'Not provided'
    end
  end

  def then_i_see_the_review_page_with_empty_details
    within('.app-summary-card__body') do
      expect(page).to have_content 'GCSE'
      expect(page).to have_content 'Not entered'
      expect(page).to have_content 'Not entered'
    end
  end
end

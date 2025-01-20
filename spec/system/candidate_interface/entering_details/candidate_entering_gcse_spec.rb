require 'rails_helper'

RSpec.describe 'Candidate entering GCSE details' do
  include CandidateHelper

  scenario 'Candidate submits their maths GCSE details and then update them' do
    given_i_am_signed_in_with_one_login

    and_i_click_on_the_maths_gcse_link
    then_i_see_the_add_gcse_maths_page

    when_i_do_not_select_any_gcse_option
    and_i_click_save_and_continue
    then_i_see_the_qualification_type_error

    when_i_select_gcse_option
    and_i_click_save_and_continue
    then_i_see_add_grade_page

    when_i_fill_in_the_grade
    and_i_click_save_and_continue
    then_i_see_add_year_page

    when_i_fill_in_the_year
    and_i_click_save_and_continue
    then_i_see_the_review_page_with_correct_details

    when_i_click_continue
    then_i_see_a_section_complete_error

    when_i_click_to_change_qualification_type
    then_i_see_the_gcse_option_selected

    when_i_select_a_different_qualification_type
    and_i_click_save_and_continue
    then_i_see_the_grade_page
    and_i_see_the_gcse_grade_entered

    when_i_enter_a_different_qualification_grade
    and_i_click_save_and_continue
    then_i_see_the_gcse_year_entered

    when_i_enter_a_different_qualification_year
    and_i_click_save_and_continue
    then_i_see_the_review_page_with_updated_year

    when_i_mark_the_section_as_completed
    and_click_continue
    then_i_see_the_maths_gcse_is_completed

    when_i_click_on_the_english_gcse_link
    then_i_see_the_add_gcse_english_page

    when_i_select_gcse_option
    and_i_click_save_and_continue
    then_i_see_add_english_grade_page

    when_i_choose_to_return_later
    then_i_am_returned_to_the_application_form_details
  end

  def and_i_click_on_the_maths_gcse_link
    click_link_or_button 'Maths GCSE or equivalent'
  end

  def when_i_select_gcse_option
    choose('GCSE')
  end

  def and_i_click_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def when_i_do_not_select_any_gcse_option; end

  def then_i_see_the_add_gcse_maths_page
    expect(page).to have_content 'What type of qualification in maths do you have?'
  end

  def then_i_see_the_review_page_with_correct_details
    expect(page).to have_content 'Maths GCSE or equivalent'

    expect(page).to have_content 'GCSE'
    expect(page).to have_content 'A'
    expect(page).to have_content '1990'
  end

  def then_i_see_the_review_page_with_updated_year
    expect(page).to have_content '2000'
  end

  def then_i_see_add_grade_page
    expect(page).to have_content t('gcse_edit_grade.page_title', subject: 'maths', qualification_type: 'GCSE')
  end

  def then_i_see_add_year_page
    expect(page).to have_content t('gcse_edit_year.page_title', subject: 'maths', qualification_type: 'GCSE')
  end

  def when_i_fill_in_the_grade
    fill_in 'Grade', with: 'A'
  end

  def when_i_fill_in_the_year
    fill_in 'Year', with: '1990'
  end

  def then_i_see_the_qualification_type_error
    expect(page).to have_content 'Select the type of qualification'
  end

  def then_i_see_the_gcse_option_selected
    expect(find_field('GCSE')).to be_checked
  end

  def then_i_see_the_grade_page
    expect(page).to have_content t('gcse_edit_grade.page_title', subject: 'maths', qualification_type: 'Scottish National 5')
  end

  def and_i_see_the_gcse_grade_entered
    expect(page).to have_css("input[value='A']")
  end

  def then_i_see_the_gcse_year_entered
    expect(page).to have_css("input[value='1990']")
  end

  def then_i_see_a_section_complete_error
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/section_complete_form.attributes.completed.blank')
  end

  def when_i_select_a_different_qualification_type
    choose('Scottish National 5')
  end

  def when_i_click_to_change_qualification_type
    find_link('Change', href: candidate_interface_gcse_details_edit_type_path(subject: 'maths')).click
  end

  def when_i_enter_a_different_qualification_grade
    fill_in 'Grade', with: 'BB'
  end

  def when_i_enter_a_different_qualification_year
    fill_in 'Year', with: '2000'
  end

  def when_i_mark_the_section_as_completed
    choose t('application_form.completed_radio')
  end

  def then_i_see_the_maths_gcse_is_completed
    expect(page).to have_css('#maths-gcse-or-equivalent-badge-id', text: 'Completed')
  end

  def and_click_continue
    click_link_or_button t('continue')
  end

  def when_i_click_continue
    and_click_continue
  end

  def when_i_click_on_the_english_gcse_link
    click_link_or_button 'English GCSE or equivalent'
  end

  def then_i_see_add_english_grade_page
    expect(page).to have_content t('multiple_gcse_edit_grade.page_title')
  end

  def then_i_see_the_add_gcse_english_page
    expect(page).to have_content 'What type of qualification in English do you have?'
  end

  def when_i_choose_to_return_later
    visit candidate_interface_gcse_review_path(subject: 'english')
    and_i_mark_the_section_as_incomplete
    and_click_continue
  end

  def and_i_mark_the_section_as_incomplete
    choose t('application_form.incomplete_radio')
  end

  def then_i_am_returned_to_the_application_form_details
    expect(page).to have_current_path candidate_interface_details_path
  end
end

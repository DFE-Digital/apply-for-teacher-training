require 'rails_helper'

RSpec.feature 'Candidate entering Non UK GCSE equivalency details' do
  include CandidateHelper

  scenario 'Candidate submits their maths Non UK GCSE equivalency details and then updates them' do
    given_i_am_signed_in
    and_the_international_gcses_flag_is_active

    when_i_visit_the_candidate_application_page
    and_i_click_on_the_maths_gcse_link
    then_i_see_the_add_gcse_maths_page

    when_i_do_not_select_any_gcse_option
    and_i_click_save_and_continue
    then_i_see_the_qualification_type_error

    when_i_select_non_uk_qualification
    and_i_fill_in_my_qualification_type
    and_i_click_save_and_continue
    then_i_see_the_add_grade_page

    when_i_fill_in_the_grade
    and_i_click_save_and_continue
    then_i_see_add_year_page

    when_i_fill_in_the_year
    and_i_click_save_and_continue
    then_i_see_the_review_page_with_correct_details

    when_i_mark_the_section_as_completed
    and_click_continue
    then_i_see_the_maths_gcse_is_completed
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_the_international_gcses_flag_is_active
    FeatureFlag.activate('international_gcses')
  end

  def given_i_am_not_signed_in; end

  def and_i_click_on_the_maths_gcse_link
    click_on 'Maths GCSE or equivalent'
  end

  def then_i_see_the_add_gcse_maths_page
    expect(page).to have_content 'Add maths GCSE grade 4 (C) or above, or equivalent'
  end

  def then_i_see_the_qualification_type_error
    expect(page).to have_content 'Enter the type of qualification'
  end

  def when_i_select_non_uk_qualification
    choose('Non-UK qualification')
  end

  def and_i_fill_in_my_qualification_type
    fill_in 'candidate-interface-gcse-qualification-type-form-non-uk-qualification-type-field', with: 'High School Diploma'
  end

  def and_i_click_save_and_continue
    click_button 'Save and continue'
  end

  def when_i_do_not_select_any_gcse_option; end

  def when_i_visit_the_candidate_application_page
    visit '/candidate/application'
  end

  def then_i_see_the_add_grade_page
    expect(page).to have_current_path candidate_interface_gcse_details_edit_grade_path('maths')
  end

  def then_i_see_the_review_page_with_correct_details
    expect(page).to have_content 'Maths GCSE or equivalent'

    expect(page).to have_content 'High School Diploma'
    expect(page).to have_content 'PASS'
    expect(page).to have_content '1990'
  end

  def then_i_see_add_grade_page
    expect(page).to have_content t('gcse_edit_grade.page_title', subject: 'maths')
  end

  def then_i_see_add_year_page
    expect(page).to have_content t('gcse_edit_year.page_title', subject: 'maths')
  end

  def when_i_fill_in_the_grade
    fill_in 'Please specify your grade', with: 'Pass'
  end

  def when_i_fill_in_the_year
    fill_in 'Enter year', with: '1990'
  end

  def then_i_see_the_non_uk_qualification_option_selected
    expect(find_field('Non-UK qualification')).to be_checked
  end

  def then_i_see_the_gcse_grade_entered
    expect(page).to have_selector("input[value='Pass']")
  end

  def then_i_see_the_gcse_year_entered
    expect(page).to have_selector("input[value='1990']")
  end

  def when_i_mark_the_section_as_completed
    check t('application_form.completed_checkbox')
  end

  def then_i_see_the_maths_gcse_is_completed
    expect(page).to have_css('#maths-gcse-or-equivalent-badge-id', text: 'Completed')
  end

  def and_click_continue
    click_button t('application_form.continue')
  end
end

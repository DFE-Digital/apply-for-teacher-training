require 'rails_helper'

RSpec.feature 'Candidate entering Non UK GCSE equivalency details' do
  include CandidateHelper

  scenario 'Candidate submits their maths Non UK GCSE equivalency details and then updates them' do
    given_i_am_signed_in

    when_i_visit_the_candidate_application_page
    and_i_click_on_the_maths_gcse_link
    then_i_see_the_add_gcse_maths_page

    when_i_do_not_select_any_gcse_option
    and_i_click_save_and_continue
    then_i_see_the_qualification_type_error

    when_i_select_non_uk_qualification
    and_i_fill_in_my_qualification_type
    and_i_click_save_and_continue
    then_i_see_the_add_institution_country_page

    when_i_do_not_select_a_country
    and_i_click_save_and_continue
    then_i_see_the_country_blank_error

    when_i_fill_in_a_valid_country
    and_i_click_save_and_continue
    then_i_see_the_add_enic_reference_page

    when_i_do_not_input_my_enic_reference_or_choose_an_equivalency
    and_i_click_save_and_continue
    then_i_see_the_do_you_have_a_enic_reference_error

    when_i_choose_yes
    and_i_click_save_and_continue
    then_i_see_the_enic_reference_blank_error
    and_i_see_the_choose_a_equivalency_option_error

    when_i_fill_in_my_enic_reference_and_choose_an_equivalency
    and_i_click_save_and_continue
    then_i_see_the_add_grade_page

    when_i_choose_other
    and_i_fill_in_my_grade
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

  def given_i_am_not_signed_in; end

  def when_i_visit_the_candidate_application_page
    visit '/candidate/application'
  end

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
    click_button t('save_and_continue')
  end

  def when_i_do_not_select_any_gcse_option; end

  def then_i_see_the_add_institution_country_page
    expect(page).to have_current_path candidate_interface_gcse_details_new_institution_country_path('maths')
  end

  def when_i_do_not_select_a_country; end

  def then_i_see_the_country_blank_error
    expect(page).to have_content 'Enter the country you studied in'
  end

  def when_i_fill_in_a_valid_country
    select 'United States'
  end

  def then_i_see_the_add_enic_reference_page
    expect(page).to have_current_path candidate_interface_gcse_details_edit_enic_path('maths')
  end

  def when_i_do_not_input_my_enic_reference_or_choose_an_equivalency; end

  def then_i_see_the_do_you_have_a_enic_reference_error
    expect(page).to have_content 'Select if you have a UK ENIC statement of comparability'
  end

  def when_i_choose_yes
    choose 'Yes'
  end

  def then_i_see_the_enic_reference_blank_error
    expect(page).to have_content 'Enter your UK ENIC reference number'
  end

  def and_i_see_the_choose_a_equivalency_option_error
    expect(page).to have_content 'Choose a comparable UK qualification'
  end

  def when_i_fill_in_my_enic_reference_and_choose_an_equivalency
    fill_in 'candidate-interface-gcse-enic-form-enic-reference-field-error', with: '12345'
    choose 'GCSE (grades A*-C / 9-4)'
  end

  def then_i_see_the_add_grade_page
    expect(page).to have_current_path candidate_interface_edit_gcse_maths_grade_path
  end

  def then_i_see_the_review_page_with_correct_details
    expect(page).to have_content 'Maths GCSE or equivalent'
    expect(page).to have_content 'High School Diploma'
    expect(page).to have_content 'Pass'
    expect(page).to have_content '1990'
    expect(page).to have_content 'United States'
    expect(page).to have_content '12345'
    expect(page).to have_content 'GCSE (grades A*-C / 9-4)'
  end

  def then_i_see_add_grade_page
    expect(page).to have_content t('gcse_edit_grade.page_title', subject: 'maths')
  end

  def then_i_see_add_year_page
    expect(page).to have_content t('gcse_edit_year.page_title', subject: 'maths', qualification_type: 'qualification')
  end

  def when_i_choose_other
    choose 'Other'
  end

  def and_i_fill_in_my_grade
    fill_in 'Grade', with: 'Pass'
  end

  def when_i_fill_in_the_year
    fill_in 'Enter year', with: '1990'
  end

  def when_i_mark_the_section_as_completed
    choose t('application_form.completed_radio')
  end

  def then_i_see_the_maths_gcse_is_completed
    expect(page).to have_css('#maths-gcse-or-equivalent-badge-id', text: 'Completed')
  end

  def and_click_continue
    click_button t('continue')
  end
end

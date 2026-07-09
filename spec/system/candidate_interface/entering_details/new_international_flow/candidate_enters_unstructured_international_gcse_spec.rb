require 'rails_helper'

RSpec.describe 'Candidate enters a GCSE equivalent qualification from outside of the UK choosing unstructured data path' do
  include CandidateHelper

  scenario 'Candidate submits their maths international qualification details with unstructured data',
           feature_flag: '2027_international_qualifications_flow' do
    given_i_am_signed_in_with_one_login

    and_i_click_on_the_maths_gcse_link
    then_i_see_the_add_gcse_maths_page

    when_i_do_not_select_any_gcse_option
    and_i_click_save_and_continue
    then_i_see_the_qualification_type_error

    when_i_select_non_uk_qualification
    and_i_click_save_and_continue
    then_i_see_the_add_institution_country_page

    when_i_do_not_select_a_country
    and_i_click_save_and_continue
    then_i_see_the_country_blank_error

    when_i_fill_in_a_country_for_which_we_have_structured_data
    and_i_click_save_and_continue
    then_i_see_the_structured_qualifications_page

    when_i_do_not_choose_a_qualification
    and_i_click_save_and_continue
    then_i_see_the_qualification_blank_error

    when_i_choose_other
    and_i_click_save_and_continue
    then_i_see_a_text_field_to_enter_another_qualification_not_listed

    when_i_enter_an_unstructured_qualification
    and_i_click_save_and_continue
    then_i_see_the_unstructured_grades_page

    when_i_do_not_choose_a_grade
    and_i_click_save_and_continue
    then_i_see_the_grade_blank_error

    when_i_enter_an_unstructured_grade
    and_i_click_save_and_continue
    then_i_see_the_add_enic_page

    when_i_choose_yes
    and_i_click_save_and_continue
    then_i_see_the_enic_reference_page

    when_i_fill_in_the_reference_number
    and_choose_an_equivalent_level
    and_i_click_save_and_continue
    then_i_see_the_year_page

    when_i_do_not_fill_in_a_year
    and_i_click_save_and_continue
    then_i_see_the_year_blank_error

    when_i_fill_in_the_year
    and_i_click_save_and_continue
    then_i_see_the_review_page
  end

private

  def and_i_click_on_the_maths_gcse_link
    click_link_or_button 'Maths GCSE or equivalent'
  end

  def then_i_see_the_add_gcse_maths_page
    expect(page).to have_text 'What type of qualification in maths do you have?'
  end

  def then_i_see_the_qualification_type_error
    expect(page).to have_text 'Select the type of qualification'
  end

  def when_i_select_non_uk_qualification
    choose('Qualification from outside the UK')
  end

  def and_i_click_save_and_continue
    click_link_or_button 'Save and continue'
  end

  def when_i_do_not_select_any_gcse_option; end

  def then_i_see_the_add_institution_country_page
    expect(page).to have_current_path candidate_interface_gcse_new_international_flow_new_institution_country_path('maths')
  end

  def when_i_do_not_select_a_country; end

  def then_i_see_the_country_blank_error
    expect(page).to have_text 'Enter the country or territory you studied in'
  end

  def when_i_fill_in_a_country_for_which_we_have_structured_data
    select 'Sierra Leone'
  end

  def then_i_see_the_structured_qualifications_page
    expect(page).to have_current_path candidate_interface_gcse_new_international_flow_new_qualifications_path('maths')
    expect(page).to have_text 'WASSCE (West African Senior School Certificate Examination)'
  end

  def when_i_choose_other
    choose 'Other maths qualification equivalent to a GCSE'
  end

  def then_i_see_a_text_field_to_enter_another_qualification_not_listed
    expect(page).to have_text 'Enter the name of your qualification'
  end

  def when_i_enter_an_unstructured_qualification
    fill_in 'candidate-interface-gcse-equivalent-qualification-form-non-structured-qualification-field-error', with: 'Example qualification'
  end

  def then_i_see_the_unstructured_grades_page
    expect(page).to have_current_path candidate_interface_gcse_new_international_flow_new_grades_path('maths')
  end

  def when_i_enter_an_unstructured_grade
    fill_in 'candidate-interface-gcse-international-structured-grades-form-non-structured-grade-field-error', with: '99%'
  end

  def then_i_see_the_add_enic_page
    expect(page).to have_current_path candidate_interface_gcse_new_international_flow_new_enic_path('maths')
  end

  def when_i_choose_yes
    choose 'Yes, I have a statement of comparability'
  end

  def then_i_see_the_enic_reference_page
    expect(page).to have_text 'Enter the UK ENIC reference number for your maths qualification'
  end

  def when_i_fill_in_the_reference_number
    fill_in 'candidate-interface-gcse-enic-form-enic-reference-field', with: '4000228363'
  end

  def and_choose_an_equivalent_level
    choose 'Between GCSE and GCE AS level'
  end

  def then_i_see_the_year_page
    expect(page).to have_text 'What year was your maths qualification awarded?'
  end

  def when_i_fill_in_the_year
    fill_in 'candidate-interface-gcse-year-form-award-year-field-error', with: '2017'
  end

  def then_i_see_the_review_page
    expect(page).to have_text 'Check your maths GCSE or equivalent'
    expect(page).to have_text 'Qualification from outside the UK'
    expect(page).to have_text 'Sierra Leone'
    expect(page).to have_text 'Example qualification'
    expect(page).to have_text 'Yes, I have a statement of comparability'
    expect(page).to have_text '4000228363'
    expect(page).to have_text 'Between GCSE and GCE AS level'
    expect(page).to have_text '2017'
  end

  def when_i_do_not_choose_a_qualification; end

  def then_i_see_the_qualification_blank_error
    expect(page).to have_text 'Select a qualification'
  end

  def when_i_do_not_enter_an_other_qualification; end

  def then_i_see_the_qualification_empty_error
    expect(page).to have_text 'Enter a qualification'
  end

  def when_i_do_not_choose_a_grade; end

  def then_i_see_the_grade_blank_error
    expect(page).to have_text 'Enter a grade'
  end

  def when_i_do_not_fill_in_a_year; end

  def then_i_see_the_year_blank_error
    expect(page).to have_text 'Enter the year you gained your qualification'
  end
end

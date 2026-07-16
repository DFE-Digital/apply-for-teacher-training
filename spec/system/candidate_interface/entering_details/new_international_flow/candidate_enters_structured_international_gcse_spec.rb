require 'rails_helper'

RSpec.describe 'Candidate enters a GCSE equivalent qualification from outside of the UK choosing structured data path' do
  include CandidateHelper

  scenario 'Candidate submits their maths international qualification details with structured data and a passing grade',
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

    when_i_fill_in_a_country_for_which_we_have_structured_data
    and_i_click_save_and_continue
    then_i_see_the_structured_qualifications_page

    when_i_choose_kcse
    and_i_click_save_and_continue
    then_i_see_the_structured_grades_page

    when_i_choose_a_passing_grade
    and_i_click_save_and_continue
    then_i_see_the_add_enic_page('maths')

    when_i_choose_waiting_for_it_to_arrive
    and_i_click_save_and_continue
    then_i_see_the_year_page

    when_i_click_back
    then_i_see_the_add_enic_page('maths')

    when_i_click_save_and_continue
    then_i_see_the_year_page

    when_i_fill_in_the_year
    and_i_click_save_and_continue
    then_i_see_the_review_page
  end

  scenario 'Candidate submits their English international qualification details with structured data and a failing grade',
           feature_flag: '2027_international_qualifications_flow' do
    given_i_am_signed_in_with_one_login

    and_i_click_on_the_english_gcse_link
    then_i_see_the_add_gcse_english_page

    when_i_do_not_select_any_gcse_option
    and_i_click_save_and_continue
    then_i_see_the_qualification_type_error

    when_i_select_non_uk_qualification
    and_i_click_save_and_continue
    then_i_see_the_add_institution_country_page_english

    when_i_fill_in_a_country_for_which_we_have_structured_data
    and_i_click_save_and_continue
    then_i_see_the_structured_qualifications_page_english

    when_i_choose_kcse
    and_i_click_save_and_continue
    then_i_see_the_structured_grades_page

    when_i_choose_a_failing_grade
    and_i_click_save_and_continue
    then_i_see_the_interruption_page

    when_i_click_provide_evidence_of_your_english_skills
    then_i_see_the_evidence_page

    when_i_do_not_provide_evidence
    and_i_click_save_and_continue
    then_i_see_the_blank_error

    when_i_provide_valid_text
    and_i_click_save_and_continue
    then_i_see_the_year_page_english

    when_i_click_back
    then_i_see_the_evidence_page

    when_i_click_save_and_continue
    then_i_see_the_year_page_english

    when_i_fill_in_the_year
    and_i_click_save_and_continue
    then_i_see_the_review_page_english
  end

  # scenario 'Candidate submits their maths international qualification details for a qualification with multiple schemas',
  #          feature_flag: '2027_international_qualifications_flow' do
  #   given_i_am_signed_in_with_one_login

  #   and_i_click_on_the_maths_gcse_link
  #   then_i_see_the_add_gcse_maths_page

  #   when_i_select_non_uk_qualification
  #   and_i_click_save_and_continue
  #   then_i_see_the_add_institution_country_page

  #   when_i_select_india
  #   and_i_click_save_and_continue
  #   then_i_see_the_structured_qualifications_page

  #   when_i_choose_icse
  #   and_i_click_save_and_continue
  #   then_i_see_the_grade_schemas_page

  #   when_i_do_not_select_any_type_option
  #   and_i_click_save_and_continue
  #   then_i_see_the_blank_type_validation_error

  #   when_i_choose_percentage
  #   and_i_click_save_and_continue
  #   then_i_see_the_percentage_input_page

  #   when_i_enter_a_percentage_with_percentage_sign
  #   and_i_click_save_and_continue
  #   then_i_see_the_validation_error_for_non_numerical_chars

  #   when_i_enter_a_percentage_below_the_pass_threshold
  #   and_i_click_save_and_continue
  #   then_i_see_the_interruption_page_maths

  #   when_i_click_back
  #   then_i_see_the_percentage_input_page

  #   when_i_enter_a_percentage_above_the_pass_threshold
  #   and_i_click_save_and_continue
  #   then_i_see_the_add_enic_page('maths')

  #   when_i_click_back
  #   then_i_see_the_percentage_input_page

  #   when_i_click_back
  #   then_i_see_the_grade_schemas_page

  #   when_i_choose_other
  #   and_i_do_not_enter_anything
  #   and_i_click_save_and_continue
  #   then_i_see_the_enter_grade_validation_error

  #   when_i_enter_my_custom_grade
  #   and_i_click_save_and_continue
  #   then_i_see_the_add_enic_page('maths')

  #   when_i_choose_waiting_for_it_to_arrive
  #   and_i_click_save_and_continue
  #   then_i_see_the_year_page

  #   when_i_fill_in_the_year
  #   and_i_click_save_and_continue
  #   then_i_see_the_review_page_for_icse_with_custom_grade
  # end

  # scenario 'Candidate submits their English international qualification details for a qualification with multiple schemas but for which we have no failing grade data',
  #          feature_flag: '2027_international_qualifications_flow' do
  #   given_i_am_signed_in_with_one_login

  #   and_i_click_on_the_english_gcse_link
  #   then_i_see_the_add_gcse_english_page

  #   when_i_select_non_uk_qualification
  #   and_i_click_save_and_continue
  #   then_i_see_the_add_institution_country_page_english

  #   when_i_select_india
  #   and_i_click_save_and_continue
  #   then_i_see_the_structured_qualifications_page_english

  #   when_i_choose_icse
  #   and_i_click_save_and_continue
  #   then_i_see_the_grade_schemas_page

  #   when_i_choose_percentage
  #   and_i_click_save_and_continue
  #   then_i_see_the_percentage_input_page

  #   when_i_enter_a_low_percentage_grade
  #   and_i_click_save_and_continue
  #   then_i_see_the_add_enic_page('english') # no interruption page

  #   when_i_choose_waiting_for_it_to_arrive
  #   and_i_click_save_and_continue
  #   then_i_see_the_year_page_english

  #   when_i_fill_in_the_year
  #   and_i_click_save_and_continue
  #   then_i_see_the_review_page_for_icse_with_percentage_grade
  # end

private

  def and_i_click_on_the_maths_gcse_link
    click_link_or_button 'Maths GCSE or equivalent'
  end

  def and_i_click_on_the_english_gcse_link
    click_link_or_button 'English GCSE or equivalent'
  end

  def then_i_see_the_add_gcse_maths_page
    expect(page).to have_text 'What type of qualification in maths do you have?'
  end

  def then_i_see_the_add_gcse_english_page
    expect(page).to have_text 'What type of qualification in English do you have?'
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
  alias_method :when_i_click_save_and_continue, :and_i_click_save_and_continue

  def when_i_click_back
    click_link_or_button 'Back'
  end

  def when_i_do_not_select_any_gcse_option; end

  def then_i_see_the_add_institution_country_page
    expect(page).to have_current_path candidate_interface_gcse_new_international_flow_new_institution_country_path('maths')
  end

  def then_i_see_the_add_institution_country_page_english
    expect(page).to have_current_path candidate_interface_gcse_new_international_flow_new_institution_country_path('english')
  end

  def when_i_fill_in_a_country_for_which_we_have_structured_data
    select 'Kenya'
  end

  def when_i_select_india
    select 'India'
  end

  def then_i_see_the_structured_qualifications_page
    expect(page).to have_current_path candidate_interface_gcse_new_international_flow_new_qualifications_path('maths')
  end

  def then_i_see_the_structured_qualifications_page_english
    expect(page).to have_current_path candidate_interface_gcse_new_international_flow_new_qualifications_path('english')
  end

  def when_i_choose_kcse
    choose 'KCSE (Kenya Certificate of Secondary Education)'
  end

  def when_i_choose_icse
    choose 'ICSE (Indian Certificate of Secondary Education)'
  end

  def then_i_see_the_structured_grades_page
    expect(page).to have_text 'What grade did you get?'
    expect(page).to have_text 'B+'
  end

  def then_i_see_the_grade_schemas_page
    expect(page).to have_text 'What type of grade did you get?'
    expect(page).to have_text 'Percentage'
    expect(page).to have_text 'Letter and number grade'
  end

  def when_i_choose_percentage
    choose 'Percentage'
  end

  def then_i_see_the_percentage_input_page
    expect(page).to have_text 'What grade did you get?'
    expect(page).to have_text '%'
  end

  def when_i_enter_a_percentage_with_percentage_sign
    fill_in 'candidate-interface-gcse-international-structured-grades-form-grade-field', with: '21%'
  end

  def when_i_enter_a_percentage_below_the_pass_threshold
    fill_in 'candidate-interface-gcse-international-structured-grades-form-grade-field-error', with: '21'
  end

  def when_i_enter_a_low_percentage_grade
    fill_in 'candidate-interface-gcse-international-structured-grades-form-grade-field', with: '2'
  end

  def when_i_enter_a_percentage_above_the_pass_threshold
    fill_in 'candidate-interface-gcse-international-structured-grades-form-grade-field', with: '99'
  end

  def then_i_see_the_validation_error_for_non_numerical_chars
    expect(page).to have_text 'Enter a whole number'
  end

  def when_i_choose_a_passing_grade
    first('input[value="B+"]').choose
  end

  def when_i_choose_a_failing_grade
    first('input[value="D"]').choose
  end

  def then_i_see_the_add_enic_page(subject)
    expect(page).to have_current_path candidate_interface_gcse_new_international_flow_new_enic_path(subject)
  end

  def when_i_choose_waiting_for_it_to_arrive
    choose "I'm waiting for it to arrive"
  end

  def then_i_see_the_year_page
    expect(page).to have_text 'What year was your maths qualification awarded?'
  end

  def then_i_see_the_year_page_english
    expect(page).to have_text 'What year was your English qualification awarded?'
  end

  def when_i_fill_in_the_year
    fill_in 'candidate-interface-gcse-year-form-award-year-field', with: '2017'
  end

  def then_i_see_the_review_page
    expect(page).to have_text 'Check your maths GCSE or equivalent'
    expect(page).to have_text 'Qualification from outside the UK'
    expect(page).to have_text 'Kenya'
    expect(page).to have_text 'KCSE (Kenya Certificate of Secondary Education)'
    expect(page).to have_text 'B+'
    expect(page).to have_text "I'm waiting for it to arrive"
    expect(page).to have_text '2017'
    expect(page).to have_no_text 'Evidence that your maths skills are at GCSE grade 4 (C) or above'
  end

  def then_i_see_the_review_page_english
    expect(page).to have_text 'Check your English GCSE or equivalent'
    expect(page).to have_text 'Qualification from outside the UK'
    expect(page).to have_text 'Kenya'
    expect(page).to have_text 'KCSE (Kenya Certificate of Secondary Education)'
    expect(page).to have_text 'D'
    expect(page).to have_text 'I completed a supplementary qualification in English which amounts to a B at GCSE'
    expect(page).to have_text '2017'
    expect(page).to have_no_text 'Do you have a UK ENIC statement of comparability?'
    expect(page).to have_no_text 'UK ENIC reference number'
    expect(page).to have_no_text 'Comparable UK qualification'
  end

  def then_i_see_the_review_page_for_icse_with_custom_grade
    expect(page).to have_text 'Check your maths GCSE or equivalent'
    expect(page).to have_text 'Qualification from outside the UK'
    expect(page).to have_text 'India'
    expect(page).to have_text 'ICSE (Indian Certificate of Secondary Education)'
    expect(page).to have_text 'Magna cum laude'
    expect(page).to have_text "I'm waiting for it to arrive"
    expect(page).to have_text '2017'
    expect(page).to have_no_text 'Evidence that your maths skills are at GCSE grade 4 (C) or above'
  end

  def then_i_see_the_review_page_for_icse_with_percentage_grade
    expect(page).to have_text 'Check your English GCSE or equivalent'
    expect(page).to have_text 'Qualification from outside the UK'
    expect(page).to have_text 'India'
    expect(page).to have_text 'ICSE (Indian Certificate of Secondary Education)'
    expect(page).to have_text '2%'
    expect(page).to have_text "I'm waiting for it to arrive"
    expect(page).to have_text '2017'
    expect(page).to have_no_text 'Evidence that your maths skills are at GCSE grade 4 (C) or above'
  end

  def then_i_see_the_interruption_page
    expect(page).to have_text 'This grade may not be a equivalent to a GCSE in English at Grade 4 (C) or above'
  end

  def then_i_see_the_interruption_page_maths
    expect(page).to have_text 'This grade may not be a equivalent to a GCSE in maths at Grade 4 (C) or above'
  end

  def when_i_click_provide_evidence_of_your_english_skills
    click_link_or_button 'Provide evidence of English skills'
  end

  def then_i_see_the_evidence_page
    expect(page).to have_text 'Provide evidence that your English skills are at GCSE grade 4 (C) or above'
    expect(page).to have_text 'Check with providers about what evidence they accept. An English as a foreign language test is not equivalent to a GCSE.'
  end

  def when_i_do_not_provide_evidence; end

  def then_i_see_the_blank_error
    expect(page).to have_text 'Enter evidence that your English skills are at GCSE grade 4 (C) or above'
  end

  def when_i_provide_valid_text
    fill_in 'candidate-interface-gcse-international-evidence-form-evidence-field-error', with: 'I completed a supplementary qualification in English which amounts to a B at GCSE'
  end

  def when_i_do_not_select_any_type_option; end

  def then_i_see_the_blank_type_validation_error
    expect(page).to have_text 'Select a type'
  end

  def when_i_choose_other
    choose 'Other'
  end

  def and_i_do_not_enter_anything; end

  def then_i_see_the_enter_grade_validation_error
    expect(page).to have_text 'Enter a grade'
  end

  def when_i_enter_my_custom_grade
    fill_in 'candidate-interface-gcse-international-grade-schemas-form-grade-field-error', with: 'Magna cum laude'
  end
end

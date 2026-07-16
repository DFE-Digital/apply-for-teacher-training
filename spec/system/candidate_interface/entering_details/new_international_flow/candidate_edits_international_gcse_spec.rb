require 'rails_helper'

RSpec.describe 'Candidate edits a GCSE equivalent qualification from outside of the UK' do
  include CandidateHelper

  scenario 'Candidate edits their maths international qualification details',
           feature_flag: '2027_international_qualifications_flow' do
    given_i_am_signed_in_with_one_login
    and_i_have_a_maths_wassce
    and_i_click_on_the_maths_gcse_link
    then_i_see_the_maths_gcse_review_page
    and_i_see_the_stored_qualification_details

    when_i_click_to_change_the_grade
    then_i_see_the_grade_step

    when_i_do_not_change_the_grade
    and_i_click_save_and_continue
    then_i_see_the_maths_gcse_review_page

    when_i_click_to_change_the_grade
    then_i_see_the_grade_step

    when_i_choose_a_different_passing_grade
    and_i_click_save_and_continue
    then_i_see_the_enic_step

    when_i_choose_waiting_for_it_to_arrive
    and_i_click_save_and_continue
    then_i_see_the_maths_gcse_review_page
    and_i_see_my_qualification_details_with_enic_information

    when_i_click_to_change_the_grade
    then_i_see_the_grade_step

    when_i_choose_a_failing_grade
    and_i_click_save_and_continue
    then_i_see_the_interruption_page

    when_i_click_to_provide_evidence
    then_i_see_the_evidence_page

    when_i_fill_in_the_evidence
    and_i_click_save_and_continue
    and_i_see_the_year_step
    and_i_click_save_and_continue
    then_i_see_the_maths_gcse_review_page

    when_i_click_to_change_my_evidence
    then_i_see_the_interruption_page

    when_i_click_back
    then_i_see_the_maths_gcse_review_page

    when_i_click_to_change_the_country
    and_i_do_not_change_anything
    and_i_click_save_and_continue
    then_i_see_the_maths_gcse_review_page

    when_i_click_to_change_the_country
    and_i_change_the_country_to_a_different_one
    and_i_click_save_and_continue
    then_reenter_the_flow_with_no_stored_values

    when_i_complete_the_flow_again_with_new_attrs
    and_i_click_save_and_continue
    then_i_see_the_review_page_with_my_new_stored_attrs
  end

  scenario 'Candidate edits their maths international qualification details where qualification has multiple schemas',
           feature_flag: '2027_international_qualifications_flow' do
    given_i_am_signed_in_with_one_login
    and_i_have_a_maths_cbse
    and_i_click_on_the_maths_gcse_link
    then_i_see_the_maths_gcse_review_page
    and_i_see_the_stored_qualification_details_for_a_cbse

    when_i_click_to_change_the_grade
    then_i_see_the_grade_schemas_step

    when_i_choose_percentage
    then_i_do_not_see_the_previously_stored_grade_in_the_input_box

    when_i_click_back # TODO: Add custom back logic to return to the type page if came from review
    then_i_see_the_maths_gcse_review_page

    when_i_click_to_change_the_grade
    then_i_see_the_grade_schemas_step

    when_i_choose_letter_and_number_grade
    and_i_click_save_and_continue
    then_i_see_the_available_options

    when_i_choose_a1
    and_i_click_save_and_continue
    then_i_see_the_enic_step

    when_i_choose_waiting_for_it_to_arrive
    and_i_click_save_and_continue
    then_i_see_the_maths_gcse_review_page
    and_i_see_my_cbse_details
  end

private

  def and_i_have_a_maths_wassce
    @application_form = current_candidate.current_application

    @maths_gsce = create(:gcse_qualification, :non_uk, application_form: @application_form, subject: 'maths',
                                                       non_uk_qualification_type: 'WASSCE (West African Senior School Certificate Examination)', grade: 'B2',
                                                       institution_country: 'GH', award_year: 2017, not_completed_explanation: nil,
                                                       enic_reason: nil, enic_reference: nil)

    @application_form.reload
    current_candidate.reload

    visit candidate_interface_details_path
  end

  def and_i_have_a_maths_cbse
    @application_form_for_cbse = current_candidate.current_application

    @maths_gsce = create(:gcse_qualification, :non_uk, application_form: @application_form_for_cbse, subject: 'maths',
                                                       non_uk_qualification_type: 'CBSE Class 10 (AISSE)', grade: 'C1',
                                                       institution_country: 'IN', award_year: 2017, not_completed_explanation: nil,
                                                       enic_reason: 'waiting', enic_reference: nil)

    @application_form_for_cbse.reload
    current_candidate.reload

    visit candidate_interface_details_path
  end

  def and_i_click_on_the_maths_gcse_link
    click_link_or_button 'Maths GCSE or equivalent'
  end

  def then_i_see_the_maths_gcse_review_page
    expect(page).to have_text 'Check your maths GCSE or equivalent'
  end

  def and_i_see_the_stored_qualification_details
    expect(page).to have_text 'Qualification from outside the UK'
    expect(page).to have_text 'Ghana'
    expect(page).to have_text 'WASSCE (West African Senior School Certificate Examination)'
    expect(page).to have_text 'B2'
    expect(page).to have_text 'Enter your ENIC status'
    expect(page).to have_text '2017'
  end

  def and_i_see_the_stored_qualification_details_for_a_cbse
    expect(page).to have_text 'Qualification from outside the UK'
    expect(page).to have_text 'India'
    expect(page).to have_text 'CBSE Class 10 (AISSE)'
    expect(page).to have_text 'C1'
    expect(page).to have_text "I'm waiting for it to arrive"
    expect(page).to have_text '2017'
  end

  def when_i_click_to_change_the_country
    within('div.govuk-summary-list__row', text: 'Country or territory') do
      click_link 'Change'
    end
  end

  def when_i_click_to_change_my_evidence
    within('div.govuk-summary-list__row', text: 'Evidence that your maths skills are at GCSE grade 4 (C) or above') do
      click_link 'Change'
    end
  end

  def when_i_click_to_change_the_grade
    within('div.govuk-summary-list__row', text: 'Grade') do
      click_link 'Change'
    end
  end

  def when_i_click_back
    click_link_or_button 'Back'
  end

  def then_i_see_the_edit_country_step
    expect(page).to have_current_path candidate_interface_gcse_new_international_flow_edit_institution_country_path('maths')
  end

  def and_i_click_save_and_continue
    click_link_or_button 'Save and continue'
  end
  alias_method :when_i_click_save_and_continue, :and_i_click_save_and_continue

  def and_i_select_a_different_country
    select 'Sierra Leone'
  end

  def and_i_change_the_country_to_a_different_one
    select 'France'
  end

  def then_i_see_the_qualification_step_again
    expect(page).to have_current_path candidate_interface_gcse_new_international_flow_edit_qualifications_path('maths')
  end

  def when_i_do_not_change_the_qualification; end

  def then_i_see_the_grade_step
    expect(page).to have_text 'What grade did you get?'
  end

  def when_i_choose_a_failing_grade
    first('input[value="E8"]').choose
  end

  def when_i_choose_a_different_passing_grade
    first('input[value="A1"]').choose
  end

  def then_i_see_the_interruption_page
    expect(page).to have_text 'This grade may not be a equivalent to a GCSE in maths at Grade 4 (C) or above'
  end

  def when_i_click_to_provide_evidence
    click_link_or_button 'Provide evidence of maths skills'
  end

  def then_i_see_the_evidence_page
    expect(page).to have_text 'Provide evidence that your maths skills are at GCSE grade 4 (C) or above'
  end

  def when_i_fill_in_the_evidence
    fill_in 'candidate-interface-gcse-international-evidence-form-evidence-field', with: 'I can count to 1000'
  end

  def and_i_see_the_year_step
    expect(page).to have_text 'What year was your maths qualification awarded?'
  end
  alias_method :then_i_see_the_year_step, :and_i_see_the_year_step

  def then_i_see_the_enic_step
    expect(page).to have_current_path candidate_interface_gcse_new_international_flow_edit_enic_path('maths')
  end
  alias_method :when_i_see_the_enic_step, :then_i_see_the_enic_step

  def when_i_choose_waiting_for_it_to_arrive
    choose "I'm waiting for it to arrive"
  end
  alias_method :and_i_choose_waiting_for_it_to_arrive, :when_i_choose_waiting_for_it_to_arrive

  def when_i_do_not_change_the_grade; end

  def and_i_do_not_change_anything; end

  def and_i_see_the_qualification_page
    expect(page).to have_text 'What qualification in maths do you have?'
  end
  alias_method :then_i_see_the_qualification_page, :and_i_see_the_qualification_page

  def and_i_see_my_qualification_details_with_enic_information
    expect(page).to have_text 'Qualification from outside the UK'
    expect(page).to have_text 'Ghana'
    expect(page).to have_text 'WASSCE (West African Senior School Certificate Examination)'
    expect(page).to have_text 'A1'
    expect(page).to have_text "I'm waiting for it to arrive"
    expect(page).to have_text '2017'
  end

  def and_i_see_my_edited_qualification_details
    expect(page).to have_text 'Qualification from outside the UK'
    expect(page).to have_text 'Sierra Leone'
    expect(page).to have_text 'WASSCE (West African Senior School Certificate Examination)'
    expect(page).to have_text 'E8'
    expect(page).to have_text 'I can count to 1000'
    expect(page).to have_text '2017'
  end

  def then_i_see_the_review_page_with_my_new_stored_attrs
    expect(page).to have_text 'Qualification from outside the UK'
    expect(page).to have_text 'France'
    expect(page).to have_text 'Baccalauréat Général'
    expect(page).to have_text '33%'
    expect(page).to have_text "I'm waiting for it to arrive"
    expect(page).to have_text '1996'
  end

  def and_i_see_my_cbse_details
    expect(page).to have_text 'Qualification from outside the UK'
    expect(page).to have_text 'India'
    expect(page).to have_text 'CBSE Class 10 (AISSE)'
    expect(page).to have_text 'A1'
    expect(page).to have_text "I'm waiting for it to arrive"
    expect(page).to have_text '2017'
  end

  def then_i_see_the_grade_schemas_step
    expect(page).to have_text 'What type of grade did you get?'
  end

  def when_i_choose_percentage
    choose 'Percentage'
  end

  def then_i_do_not_see_the_previously_stored_grade_in_the_input_box
    expect(page).to have_no_text('C1')
  end

  def when_i_choose_letter_and_number_grade
    choose 'Letter and number grade'
  end

  def then_i_see_the_available_options
    expect(page).to have_text('A1')
    expect(page).to have_text('A2')
  end

  def when_i_choose_a1
    choose 'A1'
  end

  def when_i_enter_a_custom_qualification
    fill_in 'candidate-interface-gcse-equivalent-qualification-form-non-structured-qualification-field', with: 'Baccalauréat Général'
  end

  def then_reenter_the_flow_with_no_stored_values; end

  def when_i_complete_the_flow_again_with_new_attrs
    then_i_see_the_qualification_page

    when_i_enter_a_custom_qualification
    and_i_click_save_and_continue
    expect(page).to have_text 'What grade did you get?'
    fill_in 'candidate-interface-gcse-international-structured-grades-form-non-structured-grade-field', with: '33%'
    and_i_click_save_and_continue

    when_i_see_the_enic_step
    and_i_choose_waiting_for_it_to_arrive
    and_i_click_save_and_continue
    then_i_see_the_year_step

    fill_in 'candidate-interface-gcse-year-form-award-year-field', with: '1996'
  end
end

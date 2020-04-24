require 'rails_helper'

RSpec.feature 'Entering their other qualifications' do
  include CandidateHelper

  scenario 'Candidate submits their other qualifications with the prompt_for_additional_qualifications on' do
    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_other_qualifications
    then_i_see_the_select_qualification_type_page

    when_i_do_not_select_any_type_option
    and_i_click_continue
    then_i_see_the_qualification_type_error

    when_i_select_add_a_level_qualification
    and_i_click_continue
    then_i_see_the_other_qualifications_form

    when_i_fill_in_some_of_my_qualification_but_omit_some_required_details
    and_i_submit_the_other_qualification_form
    then_i_see_validation_errors_for_my_qualification

    when_i_fill_in_my_qualification
    and_select_add_another_a_level
    and_click_save_and_continue
    then_i_see_the_other_qualifications_form
    and_the_year_and_institution_fields_are_pre_populated_with_my_previous_details

    when_i_fill_out_the_remainder_of_the_form
    and_i_choose_a_different_type_of_qualification
    and_click_save_and_continue
    then_i_see_the_select_qualification_type_page

    when_i_choose_gcse
    and_i_click_continue
    then_the_year_and_institution_fields_are_not_pre_populated_with_my_previous_details

    when_i_fill_in_my_gcse_details
    and_i_choose_not_to_add_additional_qualifications
    and_click_save_and_continue
    then_i_see_the_other_qualification_review_page
    and_i_should_see_my_qualifications

    when_i_select_add_anoher_qualification
    and_choose_as_level
    and_i_click_continue
    and_i_visit_the_other_qualification_review_page
    then_i_should_see_an_incomplete_as_level_qualification

    when_i_click_on_delete_my_first_qualification
    and_i_confirm_that_i_want_to_delete_my_additional_qualification
    then_i_can_only_see_three_qualifacitions

    when_i_click_to_change_my_first_qualification
    then_i_see_my_qualification_filled_in

    when_i_change_my_qualification
    and_click_save_and_continue
    then_i_can_check_my_revised_qualification

    when_i_click_on_continue
    then_i_should_see_the_form
    and_the_section_is_not_completed

    when_i_click_on_other_qualifications
    then_i_can_check_my_answers

    when_i_mark_this_section_as_completed
    and_i_click_on_continue
    then_i_should_be_told_i_cannot_submit_incomplete_qualifications

    when_i_delete_my_incomplete_qualification
    and_i_confirm_that_i_want_to_delete_my_additional_qualification
    then_i_can_only_see_two_qualifications

    when_i_mark_this_section_as_completed
    and_i_click_on_continue
    then_i_should_see_the_form
    and_that_the_section_is_completed
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_other_qualifications
    click_link t('page_titles.other_qualification')
  end

  def then_i_see_the_select_qualification_type_page
    expect(page).to have_current_path(candidate_interface_new_other_qualification_type_path)
  end

  def when_i_select_add_a_level_qualification
    choose 'A level'
  end

  def and_i_click_continue
    click_button 'Continue'
  end

  def then_i_see_the_other_qualifications_form
    expect(page).to have_content('Add A level qualification')
  end

  def when_i_fill_in_some_of_my_qualification_but_omit_some_required_details
    fill_in t('application_form.other_qualification.subject.label'), with: 'Believing in the Heart of the Cards'
  end

  def and_i_submit_the_other_qualification_form
    click_button t('application_form.other_qualification.base.button')
  end

  def then_i_see_validation_errors_for_my_qualification
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/other_qualification_form.attributes.institution_name.blank')
  end

  def when_i_fill_in_my_qualification
    fill_in t('application_form.other_qualification.subject.label'), with: 'Believing in the Heart of the Cards'
    fill_in t('application_form.other_qualification.institution_name.label'), with: 'Yugi College'
    fill_in t('application_form.other_qualification.grade.label'), with: 'A'
    fill_in t('application_form.other_qualification.award_year.label'), with: '2015'
  end

  def and_select_add_another_a_level
    choose 'Yes, add another A level'
  end

  def and_click_save_and_continue
    click_button 'Save and continue'
  end

  def and_the_year_and_institution_fields_are_pre_populated_with_my_previous_details
    expect(page.find('#candidate-interface-other-qualification-form-institution-name-field').value).to eq('Yugi College')
    expect(page.find('#candidate-interface-other-qualification-form-award-year-field').value).to eq('2015')
  end

  def when_i_fill_out_the_remainder_of_the_form
    fill_in t('application_form.other_qualification.subject.label'), with: 'Oh'
    fill_in t('application_form.other_qualification.grade.label'), with: 'B'
  end

  def and_i_choose_a_different_type_of_qualification
    choose 'Yes, add a different qualification'
  end

  def when_i_choose_gcse
    choose 'GCSE'
  end

  def then_the_year_and_institution_fields_are_not_pre_populated_with_my_previous_details
    expect(page.find('#candidate-interface-other-qualification-form-institution-name-field').value).to eq(nil)
    expect(page.find('#candidate-interface-other-qualification-form-award-year-field').value).to eq(nil)
  end

  def when_i_fill_in_my_gcse_details
    fill_in t('application_form.other_qualification.subject.label'), with: 'Maths'
    fill_in t('application_form.other_qualification.institution_name.label'), with: 'School'
    fill_in t('application_form.other_qualification.grade.label'), with: 'U'
    fill_in t('application_form.other_qualification.award_year.label'), with: '2012'
  end

  def and_i_choose_not_to_add_additional_qualifications
    choose 'No, not right now'
  end

  def then_i_see_the_other_qualification_review_page
    expect(page).to have_current_path(candidate_interface_review_other_qualifications_path)
  end

  def and_i_should_see_my_qualifications
    expect(page).to have_content('A level Believing in the Heart of the Cards')
    expect(page).to have_content('A level Oh')
    expect(page).to have_content('GCSE Maths')
  end

  def when_i_select_add_anoher_qualification
    click_link 'Add another qualification'
  end

  def and_choose_as_level
    choose 'AS level'
  end

  def and_i_visit_the_other_qualification_review_page
    visit candidate_interface_review_other_qualifications_path
  end

  def then_i_should_see_an_incomplete_as_level_qualification
    expect(page).to have_content('AS level')
    expect(all('.govuk-summary-list__value').last.text).to eq ''
  end

  def when_i_click_on_delete_my_first_qualification
    within(all('.app-summary-card')[0]) do
      click_link(t('application_form.other_qualification.delete'))
    end
  end

  def and_i_confirm_that_i_want_to_delete_my_additional_qualification
    click_button t('application_form.other_qualification.confirm_delete')
  end

  def then_i_can_only_see_three_qualifacitions
    expect(page).not_to have_content 'A level Losing to Yugi'
    expect(page).to have_content('A level Oh')
    expect(page).to have_content('GCSE Maths')
    expect(page).to have_content('AS level')
  end

  def when_i_click_to_change_my_first_qualification
    first('.govuk-summary-list__actions').click_link 'Change'
  end

  def then_i_see_my_qualification_filled_in
    expect(page).to have_selector("input[value='A level']")
    expect(page).to have_selector("input[value='Oh']")
    expect(page).to have_selector("input[value='Yugi College']")
    expect(page).to have_selector("input[value='B']")
    expect(page).to have_selector("input[value='2015']")
  end

  def when_i_change_my_qualification
    fill_in t('application_form.other_qualification.subject.label'), with: 'How to Win Against Kaiba'
  end

  def then_i_can_check_my_revised_qualification
    expect(page).to have_content 'A level How to Win Against Kaiba'
  end

  def when_i_click_on_continue
    click_button t('application_form.other_qualification.review.button')
  end

  def and_the_section_is_not_completed
    expect(page).not_to have_css('#academic-and-other-relevant-qualifications-badge-id', text: 'Completed')
  end

  def then_i_can_check_my_answers
    then_i_can_check_my_revised_qualification
  end

  def when_i_mark_this_section_as_completed
    check t('application_form.other_qualification.review.completed_checkbox')
  end

  def and_i_click_on_continue
    when_i_click_on_continue
  end

  def then_i_should_be_told_i_cannot_submit_incomplete_qualifications
    expect(page).to have_content('You must fill in all your qualifications to complete this section')
  end

  def when_i_delete_my_incomplete_qualification
    within(all('.app-summary-card')[2]) do
      click_link(t('application_form.other_qualification.delete'))
    end
  end

  def then_i_can_only_see_two_qualifications
    expect(page).not_to have_content 'A level Losing to Yugi'
    expect(page).not_to have_content('AS level')
    expect(page).to have_content('A level How to Win Against Kaiba')
    expect(page).to have_content('GCSE Maths')
  end

  def then_i_should_see_the_form
    expect(page).to have_content(t('page_titles.application_form'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#academic-and-other-relevant-qualifications-badge-id', text: 'Completed')
  end

  def when_i_do_not_select_any_type_option; end

  def then_i_see_the_qualification_type_error
    expect(page).to have_content 'Enter the type of qualification'
  end
end

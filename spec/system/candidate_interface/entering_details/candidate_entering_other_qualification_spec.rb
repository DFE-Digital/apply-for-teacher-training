require 'rails_helper'

RSpec.feature 'Entering their other qualifications' do
  include CandidateHelper

  scenario 'Candidate submits their other qualifications' do
    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_other_qualifications
    then_i_see_the_select_qualification_type_page

    when_i_do_not_select_any_type_option
    and_i_click_continue
    then_i_see_the_qualification_type_error

    when_i_select_add_a_level_qualification
    then_i_see_the_other_qualifications_form
    and_the_suggested_subject_data_matches_the_as_and_a_level_subjects_data

    when_i_submit_in_some_of_my_qualification_but_omit_some_required_details
    then_i_see_validation_errors_for_my_qualification

    when_i_fill_in_my_qualification_details
    and_i_choose_to_add_another_a_level_qualification
    then_i_see_the_other_qualifications_form
    and_the_year_field_is_pre_populated_with_my_previous_details

    when_i_fill_out_the_remainder_of_the_form
    and_i_choose_a_different_type_of_qualification
    then_i_see_the_select_qualification_type_page

    when_i_choose_other
    and_i_click_continue
    then_the_year_field_is_not_pre_populated_with_my_previous_details

    when_i_fill_in_my_other_qualifications_details
    and_i_choose_not_to_add_additional_qualifications
    and_click_save_and_continue
    then_i_see_the_other_qualification_review_page
    and_i_should_see_my_qualifications
    and_my_other_uk_qualification_has_the_correct_format

    when_i_select_add_another_qualification
    and_choose_as_level
    then_the_form_is_empty
    and_i_visit_the_other_qualification_review_page
    then_i_should_not_see_an_incomplete_as_level_qualification

    when_i_click_on_delete_my_first_qualification
    and_i_confirm_that_i_want_to_delete_my_additional_qualification
    then_i_can_only_see_two_qualifications

    when_i_click_to_change_my_first_qualification
    then_i_see_the_qualification_type_form

    when_i_click_continue
    then_i_see_the_other_qualification_review_page
    and_no_changes_have_occurred

    when_i_click_to_change_my_first_qualification
    when_i_change_the_qualification_type_to_gcse
    and_i_click_continue
    then_i_see_my_qualification_details_filled_in
    and_the_suggested_subject_data_matches_the_gcse_subjects_data # move out?

    when_i_change_my_qualification
    and_click_save_and_continue
    then_i_can_check_my_revised_qualification

    when_i_click_continue
    then_i_see_a_section_complete_error

    when_i_mark_this_section_as_incomplete
    and_i_click_on_continue
    then_i_should_see_the_form
    and_the_section_is_not_completed

    when_i_click_on_other_qualifications
    then_i_can_check_my_answers

    when_i_mark_this_section_as_completed
    and_i_have_an_incomplete_qualification
    and_i_click_on_continue
    then_i_should_be_told_i_cannot_submit_incomplete_qualifications

    when_i_delete_my_incomplete_qualification
    and_i_confirm_that_i_want_to_delete_my_additional_qualification

    when_i_mark_this_section_as_completed
    and_i_click_on_continue
    and_that_the_section_is_completed

    when_i_click_on_other_qualifications
    and_i_delete_my_remaining_qualifications
    then_i_see_the_select_qualification_type_page

    when_i_click_back_to_application_form
    then_i_see_the_section_is_marked_as_incomplete
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_other_qualifications
    click_link t('page_titles.other_qualifications')
  end

  def then_i_see_the_select_qualification_type_page
    expect(page).to have_current_path(candidate_interface_other_qualification_type_path)
  end

  def when_i_select_add_a_level_qualification
    choose 'A level'
    click_button t('continue')
  end

  def and_i_click_continue
    click_button t('continue')
  end
  alias_method :when_i_click_continue, :and_i_click_continue

  def then_i_see_the_other_qualifications_form
    expect(page).to have_content('Add A level qualification')
  end

  def and_the_suggested_subject_data_matches_the_as_and_a_level_subjects_data
    suggested_subjects = find('#subject-autosuggest-data')['data-source']

    expect(JSON[suggested_subjects]).to eq(A_AND_AS_LEVEL_SUBJECTS)
  end

  def when_i_submit_in_some_of_my_qualification_but_omit_some_required_details
    fill_in t('application_form.other_qualification.subject.label'), with: 'Believing in the Heart of the Cards'
    click_button t('save_and_continue')
  end

  def then_i_see_validation_errors_for_my_qualification
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/other_qualification_details_form.attributes.award_year.blank')
  end

  def when_i_fill_in_my_qualification_details
    fill_in t('application_form.other_qualification.subject.label'), with: 'Believing in the Heart of the Cards'
    fill_in t('application_form.other_qualification.grade.label'), with: 'A'
    fill_in t('application_form.other_qualification.award_year.label'), with: '2015'
  end

  def and_i_choose_to_add_another_a_level_qualification
    choose 'Yes, add another A level'
    click_button t('save_and_continue')
  end

  def and_click_save_and_continue
    click_button t('save_and_continue')
  end

  def and_the_year_field_is_pre_populated_with_my_previous_details
    expect(page.find('#candidate-interface-other-qualification-details-form-award-year-field').value).to eq('2015')

    # Test that the wizard data is cleared when starting a new qualification
    expect(page.find('#candidate-interface-other-qualification-details-form-grade-field').value).to eq(nil)
  end

  def when_i_fill_out_the_remainder_of_the_form
    fill_in t('application_form.other_qualification.subject.label'), with: 'Oh'
    fill_in t('application_form.other_qualification.grade.label'), with: 'B'
  end

  def and_i_choose_a_different_type_of_qualification
    choose 'Yes, add a different qualification'
    click_button t('save_and_continue')
  end

  def when_i_choose_other
    choose 'Other'
    within('#candidate-interface-other-qualification-type-form-qualification-type-other-conditional') do
      fill_in 'Qualification name', with: 'Access Course'
    end
  end

  def then_the_year_field_is_not_pre_populated_with_my_previous_details
    expect(page.find('#candidate-interface-other-qualification-details-form-award-year-field').value).to eq(nil)
  end

  def when_i_fill_in_my_other_qualifications_details
    # fill_in t('application_form.other_qualification.qualification_type.label'), with: 'Access Course'
    fill_in t('application_form.other_qualification.subject.label'), with: 'History, English and Psychology'
    fill_in t('application_form.other_qualification.grade.label'), with: 'Distinction'
    fill_in t('application_form.other_qualification.award_year.label'), with: '2012'
  end

  def and_i_choose_not_to_add_additional_qualifications
    choose 'No, not at the moment'
  end

  def then_i_see_the_other_qualification_review_page
    expect(page).to have_current_path(candidate_interface_review_other_qualifications_path)
  end

  def and_i_should_see_my_qualifications
    expect(page).to have_content('A level Believing in the Heart of the Cards')
    expect(page).to have_content('A level Oh')
    expect(page).to have_content('Access Course History, English and Psychology')
  end

  def and_my_other_uk_qualification_has_the_correct_format
    @application = current_candidate.current_application
    expect(@application.application_qualifications.last.qualification_type).to eq 'Other'
    expect(@application.application_qualifications.last.other_uk_qualification_type).to eq 'Access Course'
    expect(@application.application_qualifications.last.subject).to eq 'History, English and Psychology'
  end

  def when_i_click_the_back_button
    visit candidate_interface_other_qualification_details_path
  end

  def and_update_the_subject
    fill_in t('application_form.other_qualification.subject.label'), with: 'Winning at life'
  end

  def then_i_should_see_the_review_page_with_a_flash_warning
    expect(page).to have_content "To update one of your qualifications use the 'Change' links below"
    expect(page).to have_content 'Access Course, History, English and Psychology'
  end

  def when_i_select_add_another_qualification
    click_link 'Add another qualification'
  end

  def and_choose_as_level
    choose 'AS level'
    and_i_click_continue
  end

  def then_the_form_is_empty
    # Fix for bug that caused data to be persisted between qualifications
    expect(page.find('#candidate-interface-other-qualification-details-form-grade-field').value).to eq(nil)
    expect(page.find('#candidate-interface-other-qualification-details-form-award-year-field').value).to eq(nil)
  end

  def and_i_visit_the_other_qualification_review_page
    visit candidate_interface_review_other_qualifications_path
  end

  def then_i_should_not_see_an_incomplete_as_level_qualification
    expect(page).not_to have_content('AS level')
    expect(all('.govuk-summary-list__value').last.text).not_to eq 'Not entered'
  end

  def when_i_click_on_delete_my_first_qualification
    within(all('.app-summary-card')[0]) do
      click_link(t('application_form.other_qualification.delete'))
    end
  end

  def and_i_confirm_that_i_want_to_delete_my_additional_qualification
    click_button t('application_form.other_qualification.confirm_delete')
  end

  def then_i_can_only_see_two_qualifications
    expect(page).not_to have_content 'A level Losing to Yugi'
    expect(page).to have_content('A level Oh')
    expect(page).to have_content('Access Course History, English and Psychology')
    expect(page).not_to have_content('AS level')
  end

  def when_i_click_to_change_my_first_qualification
    within(first('.app-summary-card')) { click_change_link('qualification') }
  end

  def then_i_see_the_qualification_type_form
    expect(page).to have_current_path(
      candidate_interface_edit_other_qualification_type_path(
        @application.application_qualifications.first.id,
      ),
    )
  end

  def when_i_change_the_qualification_type_to_gcse
    choose 'GCSE'
  end

  def and_no_changes_have_occurred
    expect(page).to have_content('A level Oh')
    expect(page).to have_content('Access Course History, English and Psychology')
  end

  def then_i_see_my_qualification_details_filled_in
    expect(page).to have_selector("input[value='Oh']")
    expect(page).to have_selector("input[value='B']")
    expect(page).to have_selector("input[value='2015']")
  end

  def and_the_suggested_subject_data_matches_the_gcse_subjects_data
    suggested_subjects = find('#subject-autosuggest-data')['data-source']

    expect(JSON[suggested_subjects]).to eq(GCSE_SUBJECTS)
  end

  def when_i_change_my_qualification
    fill_in t('application_form.other_qualification.subject.label'), with: 'How to Win Against Kaiba'
  end

  def then_i_can_check_my_revised_qualification
    expect(page).to have_content 'GCSE How to Win Against Kaiba'
  end

  def when_i_click_on_continue
    click_button t('continue')
  end

  def and_the_section_is_not_completed
    expect(page).not_to have_css('#academic-and-other-relevant-qualifications-badge-id', text: 'Completed')
  end

  def then_i_can_check_my_answers
    then_i_can_check_my_revised_qualification
  end

  def when_i_mark_this_section_as_completed
    choose t('application_form.completed_radio')
  end

  def when_i_mark_this_section_as_incomplete
    choose t('application_form.incomplete_radio')
  end

  def and_i_have_an_incomplete_qualification
    current_candidate.current_application.application_qualifications.create!(
      level: 'other',
      qualification_type: 'AS level',
    )
  end

  def and_i_click_on_continue
    when_i_click_on_continue
  end

  def then_i_see_a_section_complete_error
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/section_complete_form.attributes.completed.blank')
  end

  def then_i_should_be_told_i_cannot_submit_incomplete_qualifications
    expect(page).to have_content('You must fill in all your qualifications to complete this section')
  end

  def when_i_delete_my_incomplete_qualification
    within(all('.app-summary-card')[2]) do
      click_link(t('application_form.other_qualification.delete'))
    end
  end

  def then_i_should_see_the_form
    expect(page).to have_content(t('page_titles.application_form'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#a-levels-and-other-qualifications-badge-id', text: 'Completed')
  end

  def when_i_do_not_select_any_type_option; end

  def then_i_see_the_qualification_type_error
    expect(page).to have_content 'Enter the type of qualification'
  end

  def and_i_delete_my_remaining_qualifications
    when_i_click_on_delete_my_first_qualification
    and_i_confirm_that_i_want_to_delete_my_additional_qualification
    when_i_click_on_delete_my_first_qualification
    and_i_confirm_that_i_want_to_delete_my_additional_qualification
  end

  def when_i_click_back_to_application_form
    click_link 'Back to application'
  end

  def then_i_see_the_section_is_marked_as_incomplete
    expect(page).to have_css('#a-levels-and-other-qualifications-badge-id', text: 'Incomplete')
  end
end

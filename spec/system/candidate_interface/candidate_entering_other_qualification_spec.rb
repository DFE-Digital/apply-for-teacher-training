require 'rails_helper'

RSpec.feature 'Entering their other qualifications' do
  include CandidateHelper

  scenario 'Candidate submits their other qualifications' do
    given_i_am_not_signed_in
    and_i_visit_the_other_qualifications_page
    then_i_see_the_homepage

    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_other_qualifications
    then_i_see_the_other_qualifications_form

    when_i_fill_in_some_of_my_qualification_but_omit_some_required_details
    and_i_submit_the_other_qualification_form
    then_i_see_validation_errors_for_my_qualification

    when_i_fill_in_my_qualification
    and_i_submit_the_other_qualification_form
    then_i_can_check_my_qualification

    when_i_click_on_add_another_qualification
    then_i_see_the_other_qualifications_form

    when_i_fill_in_another_qualification
    and_i_submit_the_other_qualification_form
    then_i_can_check_additional_qualification

    when_i_click_on_delete_my_additional_qualification
    and_i_confirm_that_i_want_to_delete_my_additional_qualification
    then_i_can_only_see_my_qualification

    when_i_click_to_change_my_qualification
    then_i_see_my_qualification_filled_in

    when_i_change_my_qualification
    and_i_submit_the_other_qualification_form
    then_i_can_check_my_revised_qualification

    when_i_click_on_continue
    then_i_should_see_the_form
    and_the_section_is_not_completed

    when_i_click_on_other_qualifications
    then_i_can_check_my_answers

    when_i_mark_this_section_as_completed
    and_i_click_on_continue
    then_i_should_see_the_form
    and_that_the_section_is_completed
  end

  def given_i_am_not_signed_in; end

  def and_i_visit_the_other_qualifications_page
    visit candidate_interface_new_other_qualification_path
  end

  def then_i_see_the_homepage
    expect(page).to have_current_path(candidate_interface_start_path)
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

  def then_i_see_the_other_qualifications_form
    expect(page).to have_content(t('page_titles.add_other_qualification'))
  end

  def when_i_fill_in_some_of_my_qualification_but_omit_some_required_details
    fill_in t('application_form.other_qualification.qualification_type.label'), with: 'A-Level'
    fill_in t('application_form.other_qualification.subject.label'), with: 'Believing in the Heart of the Cards'
  end

  def and_i_submit_the_other_qualification_form
    click_button t('application_form.other_qualification.base.button')
  end

  def then_i_see_validation_errors_for_my_qualification
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/other_qualification_form.attributes.institution_name.blank')
  end

  def when_i_fill_in_my_qualification
    fill_in t('application_form.other_qualification.qualification_type.label'), with: 'A-Level'
    fill_in t('application_form.other_qualification.subject.label'), with: 'Believing in the Heart of the Cards'
    fill_in t('application_form.other_qualification.institution_name.label'), with: 'Yugi College'
    fill_in t('application_form.other_qualification.grade.label'), with: 'A'
    fill_in t('application_form.other_qualification.award_year.label'), with: '2015'
  end

  def then_i_can_check_my_qualification
    expect(page).to have_content t('application_form.other_qualification.qualification.label')
    expect(page).to have_content 'A-Level Believing in the Heart of the Cards'
  end

  def when_i_click_on_add_another_qualification
    click_link t('application_form.other_qualification.another.button')
  end

  def then_i_see_the_other_qualifications_form_with_some_details_of_my_last_autofilled
    then_i_see_the_other_qualifications_form

    expect(page).to have_selector("input[value='A-Level']")
    expect(page).to have_selector("input[value='Yugi College']")
    expect(page).to have_selector("input[value='2015']")
  end

  def when_i_fill_in_another_qualification
    fill_in t('application_form.other_qualification.qualification_type.label'), with: 'A-Level'
    fill_in t('application_form.other_qualification.subject.label'), with: 'Losing to Yugi'
    fill_in t('application_form.other_qualification.institution_name.label'), with: 'Kaiba College'
    fill_in t('application_form.other_qualification.grade.label'), with: 'C'
    fill_in t('application_form.other_qualification.award_year.label'), with: '2016'
  end

  def then_i_can_check_additional_qualification
    expect(page).to have_content t('application_form.other_qualification.qualification.label')
    expect(page).to have_content 'A-Level Losing to Yugi'
  end

  def when_i_click_on_delete_my_additional_qualification
    click_link(t('application_form.other_qualification.delete'), match: :first)
  end

  def and_i_confirm_that_i_want_to_delete_my_additional_qualification
    click_button t('application_form.other_qualification.confirm_delete')
  end

  def then_i_can_only_see_my_qualification
    then_i_can_check_my_qualification
    expect(page).not_to have_content 'A-Level Losing to Yugi'
  end

  def when_i_click_to_change_my_qualification
    first('.govuk-summary-list__actions').click_link 'Change'
  end

  def then_i_see_my_qualification_filled_in
    expect(page).to have_selector("input[value='A-Level']")
    expect(page).to have_selector("input[value='Believing in the Heart of the Cards']")
    expect(page).to have_selector("input[value='Yugi College']")
    expect(page).to have_selector("input[value='A']")
    expect(page).to have_selector("input[value='2015']")
  end

  def when_i_change_my_qualification
    fill_in t('application_form.other_qualification.subject.label'), with: 'How to Win Against Kaiba'
  end

  def then_i_can_check_my_revised_qualification
    expect(page).to have_content 'A-Level How to Win Against Kaiba'
  end

  def when_i_click_on_continue
    click_button t('application_form.other_qualification.review.button')
  end

  def and_the_section_is_not_completed
    expect(page).not_to have_css('#other-qualifications-completed', text: 'Completed')
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

  def then_i_should_see_the_form
    expect(page).to have_content(t('page_titles.application_form'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#other-qualifications-completed', text: 'Completed')
  end
end

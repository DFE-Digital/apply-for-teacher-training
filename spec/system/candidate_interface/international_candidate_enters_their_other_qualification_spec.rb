require 'rails_helper'

RSpec.feature 'Non-uk Other qualifications' do
  include CandidateHelper

  scenario 'International candidate enters their other non-uk qualification' do
    given_i_am_signed_in
    and_the_international_other_qualifications_flag_is_active
    and_i_visit_the_site

    when_i_click_on_other_qualifications
    then_i_see_the_select_qualification_type_page

    when_i_do_not_select_any_type_option
    and_i_click_continue
    then_i_see_the_qualification_type_error

    when_i_select_add_other_non_uk_qualification
    and_i_fill_in_the_name_of_my_qualification
    and_i_click_continue
    then_i_see_the_other_qualifications_form

    when_i_fill_in_some_of_my_qualification_but_omit_some_required_details
    and_i_submit_the_other_qualification_form
    then_i_see_validation_errors_for_my_qualification

    when_i_fill_in_my_qualification
    and_i_choose_not_to_add_another_non_uk_qualification
    and_click_save_and_continue
    then_i_see_the_other_qualification_review_page
    and_i_should_see_my_qualification

    when_i_click_to_change_my_first_qualification_type
    then_i_see_my_qualification_type_filled_in

    when_i_change_my_qualification_type
    and_i_click_continue
    then_i_can_check_my_revised_qualification_type

    when_i_click_to_change_my_first_qualification
    then_i_see_my_qualification_filled_in

    when_i_change_my_qualification
    and_click_save_and_continue
    then_i_can_check_my_revised_qualification

    when_i_mark_this_section_as_completed
    and_i_click_continue
    then_i_should_see_the_form
    and_that_the_section_is_completed
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_the_international_other_qualifications_flag_is_active
    FeatureFlag.activate('international_other_qualifications')
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

  def when_i_do_not_select_any_type_option; end

  def when_i_select_add_other_non_uk_qualification
    choose 'Non-UK qualification'
  end

  def and_i_fill_in_the_name_of_my_qualification
    fill_in 'candidate-interface-other-qualification-type-form-non-uk-qualification-type-field', with: 'Master Rules'
  end

  def and_i_click_continue
    click_button 'Continue'
  end

  def then_i_see_the_other_qualifications_form
    expect(page).to have_content('Add Master Rules qualification')
  end

  def when_i_fill_in_some_of_my_qualification_but_omit_some_required_details
    fill_in t('application_form.other_qualification.subject.label'), with: 'Believing in the Heart of the Cards'
  end

  def and_i_submit_the_other_qualification_form
    click_button t('application_form.other_qualification.base.button')
  end

  def then_i_see_validation_errors_for_my_qualification
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/other_qualification_form.attributes.award_year.blank')
  end

  def when_i_fill_in_my_qualification
    fill_in t('application_form.other_qualification.subject.label'), with: 'Believing in the Heart of the Cards'
    fill_in t('application_form.other_qualification.institution_name.label'), with: 'Yugi College'
    select 'Japan'
    fill_in t('application_form.other_qualification.award_year.label'), with: '2015'
  end

  def and_i_choose_not_to_add_another_non_uk_qualification
    choose 'No, not at the moment'
  end

  def and_click_save_and_continue
    click_button 'Save and continue'
  end

  def then_i_see_the_other_qualification_review_page
    expect(page).to have_current_path(candidate_interface_review_other_qualifications_path)
  end

  def and_i_should_see_my_qualification
    expect(page).to have_content('Master Rules')
    expect(page).to have_content('Believing in the Heart of the Cards')
    expect(page).to have_content('Yugi College, Japan')
    expect(page).to have_content('2015')
  end

  def when_i_click_to_change_my_first_qualification_type
    first('.govuk-summary-list__actions').click_link 'Change'
  end

  def then_i_see_my_qualification_type_filled_in
    expect(page).to have_selector("input[value='Master Rules']")
  end

  def when_i_change_my_qualification_type
    fill_in 'candidate-interface-other-qualification-type-form-non-uk-qualification-type-field', with: 'Battle'
  end

  def then_i_can_check_my_revised_qualification_type
    expect(page).to have_content 'Battle'
  end

  def when_i_click_to_change_my_first_qualification
    all('.govuk-summary-list__actions')[1].click_link 'Change'
  end

  def then_i_see_my_qualification_filled_in
    expect(page).to have_selector("input[value='Believing in the Heart of the Cards']")
    expect(page).to have_selector("input[value='2015']")
    expect(first('#candidate-interface-other-qualification-form-institution-country-field').value).to eq('Japan')
  end

  def when_i_change_my_qualification
    fill_in t('application_form.other_qualification.grade.label'), with: 'Champion'
  end

  def then_i_can_check_my_revised_qualification
    expect(page).to have_content 'Champion'
  end

  def and_the_section_is_not_completed
    expect(page).not_to have_css('#academic-and-other-relevant-qualifications-badge-id', text: 'Completed')
  end

  def when_i_mark_this_section_as_completed
    check t('application_form.other_qualification.review.completed_checkbox')
  end

  def then_i_should_see_the_form
    expect(page).to have_content(t('page_titles.application_form'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#academic-and-other-relevant-qualifications-badge-id', text: 'Completed')
  end

  def then_i_see_the_qualification_type_error
    expect(page).to have_content 'Enter the type of qualification'
  end
end

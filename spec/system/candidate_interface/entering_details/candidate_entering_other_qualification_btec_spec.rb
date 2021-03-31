require 'rails_helper'

RSpec.feature 'Entering their other qualifications' do
  include CandidateHelper

  scenario 'Candidate submits their BTEC qualification' do
    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_other_qualifications
    then_i_see_the_select_qualification_type_page

    when_i_attempt_to_add_a_btec
    then_i_see_the_add_btec_qualifications_form

    when_i_fill_in_some_of_my_qualification_but_omit_some_required_details
    and_i_submit_the_other_qualification_form
    then_i_see_validation_errors_for_my_qualification

    when_i_complete_the_form
    then_i_see_my_btec_on_the_review_page
    and_my_other_uk_qualification_has_the_correct_format

    when_i_click_change_qualification_type
    and_change_qualification_to_gcse
    then_i_should_see_simple_grade_prompt

    when_i_submit_gcse_details
    then_i_see_my_gcse_on_the_review_page
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

  def when_i_attempt_to_add_a_btec
    choose 'Other'
    fill_in 'candidate-interface-other-qualification-type-form-other-uk-qualification-type-field', with: 'BTEC'
    click_button t('continue')
  end

  def then_i_see_the_add_btec_qualifications_form
    expect(page).to have_content('Add BTEC qualification')
  end

  def when_i_fill_in_some_of_my_qualification_but_omit_some_required_details
    fill_in t('application_form.other_qualification.subject.label'), with: 'Music Theory'
    fill_in t('application_form.other_qualification.award_year.label'), with: '2015'
  end

  def and_i_submit_the_other_qualification_form
    click_button t('save_and_continue')
  end

  def then_i_see_validation_errors_for_my_qualification
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/other_qualification_details_form.attributes.grade.blank')
  end

  def when_i_complete_the_form
    choose 'Merit'
    click_button t('save_and_continue')
  end

  def then_i_see_my_btec_on_the_review_page
    expect(page).to have_current_path(candidate_interface_review_other_qualifications_path)

    expect(page).to have_content('BTEC')
    expect(page).to have_content('Music Theory')
    expect(page).to have_content('2015')
    expect(page).to have_content('Merit')
  end

  def and_my_other_uk_qualification_has_the_correct_format
    @application = current_candidate.current_application
    expect(@application.application_qualifications.last.qualification_type).to eq 'Other'
    expect(@application.application_qualifications.last.other_uk_qualification_type).to eq 'BTEC'
    expect(@application.application_qualifications.last.subject).to eq 'Music Theory'
  end

  def when_i_click_change_qualification_type
    within(first('.app-summary-card')) { click_change_link('qualification') }
  end

  def and_change_qualification_to_gcse
    choose 'GCSE'
    click_button t('continue')
  end

  def then_i_should_see_simple_grade_prompt
    expect(page).not_to have_field('Merit')
    expect(page).to have_field('Grade')
  end

  def when_i_submit_gcse_details
    fill_in t('application_form.other_qualification.grade.label'), with: 'C'
    fill_in t('application_form.other_qualification.award_year.label'), with: '2013'
    click_button t('save_and_continue')
  end

  def then_i_see_my_gcse_on_the_review_page
    expect(page).to have_current_path(candidate_interface_review_other_qualifications_path)

    expect(page).not_to have_content('BTEC')
    expect(page).to have_content('GCSE')
    expect(page).to have_content('Music Theory')
    expect(page).to have_content('2013')
    expect(page).to have_content('C')
  end
end

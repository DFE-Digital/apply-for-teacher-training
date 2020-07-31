require 'rails_helper'

RSpec.feature 'Candidate submits the application' do
  include CandidateHelper
  include EFLHelper

  scenario 'International candidate completes and submits an application' do
    given_i_am_signed_in
    and_the_efl_feature_flag_is_active
    and_the_international_personal_details_feature_flag_is_active

    when_i_have_completed_everything_except_the_efl_section
    when_i_review_my_application
    then_i_should_see_the_efl_section_is_incomplete
    when_i_confirm_my_application
    then_i_see_an_error_about_the_efl_section

    when_i_complete_the_efl_section
    then_i_should_see_all_sections_are_complete

    when_i_review_my_application
    then_i_can_see_my_course_choices
    and_i_can_see_my_personal_details
    and_i_can_see_my_efl_qualification

    when_i_confirm_my_application
    when_i_choose_not_to_fill_in_the_equality_and_diversity_survey
    when_i_choose_not_to_provide_further_information
    and_i_submit_the_application

    then_i_can_see_my_application_has_been_successfully_submitted
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_the_international_personal_details_feature_flag_is_active
    FeatureFlag.activate('international_personal_details')
  end

  def when_i_have_completed_everything_except_the_efl_section
    # Consider moving some of this into CandidateHelper once International
    # feature flags have been removed, especially the efl_section and
    # international_personal_details flags.
    given_courses_exist
    visit candidate_interface_application_form_path

    click_link 'Course choices'
    candidate_fills_in_course_choices

    # Basic personal details
    click_link t('page_titles.personal_details')
    scope = 'application_form.personal_details'
    fill_in t('first_name.label', scope: scope), with: 'Lando'
    fill_in t('last_name.label', scope: scope), with: 'Calrissian'
    fill_in 'Day', with: '6'
    fill_in 'Month', with: '4'
    fill_in 'Year', with: '1937'
    click_button t('complete_form_button', scope: scope)

    # Nationality
    check 'Other'
    within all('.govuk-form-group')[1] do
      select 'Belgian'
    end
    click_button t('complete_form_button', scope: scope)

    # Right to work
    choose 'I do not know'
    click_button t('complete_form_button', scope: scope)

    # Mark Personal Details complete
    check t('application_form.completed_checkbox')
    click_button 'Continue'

    click_link t('page_titles.contact_details')
    visit candidate_interface_contact_details_edit_base_path
    candidate_fills_in_contact_details

    click_link t('page_titles.work_history')
    candidate_fills_in_work_experience

    click_link t('page_titles.volunteering.short')
    candidate_fills_in_volunteering_role

    click_link t('page_titles.training_with_a_disability')
    candidate_fills_in_disability_info

    click_link t('page_titles.suitability_to_work_with_children')
    candidate_fills_in_safeguarding_issues

    click_link t('page_titles.degree')
    candidate_fills_in_their_degree

    click_link 'Maths GCSE or equivalent'
    candidate_fills_in_a_gcse

    click_link 'English GCSE or equivalent'
    candidate_fills_in_a_gcse

    click_link 'Science GCSE or equivalent'
    candidate_explains_a_missing_gcse

    click_link 'Academic and other relevant qualifications'
    candidate_fills_in_their_other_qualifications

    click_link 'Why do you want to be a teacher?'
    candidate_fills_in_becoming_a_teacher

    click_link 'What do you know about the subject you want to teach?'
    candidate_fills_in_subject_knowledge

    click_link t('page_titles.interview_preferences')
    candidate_fills_in_interview_preferences

    candidate_provides_two_referees
  end

  def when_i_review_my_application
    click_link 'Check and submit your application'
  end

  def then_i_should_see_the_efl_section_is_incomplete
    expect(page).to have_selector "[aria-describedby='missing-efl']"
  end

  def then_i_see_an_error_about_the_efl_section
    within '#missing-efl-error' do
      expect(page).to have_content 'English as a foreign language not marked as complete'
    end
  end

  def when_i_complete_the_efl_section
    within '#missing-efl-error' do
      click_link 'Complete section'
    end

    choose 'No, English is not a foreign language to me'
    click_button 'Continue'
    check t('application_form.completed_checkbox')
    click_button 'Continue'
  end

  def then_i_should_see_all_sections_are_complete
    CandidateHelper::APPLICATION_FORM_SECTIONS.each do |section|
      expect(page).not_to have_selector "[aria-describedby='missing-#{section}']"
    end
  end

  def then_i_can_see_my_course_choices
    expect(page).to have_content 'Gorse SCITT'
    expect(page).to have_content 'Primary (2XT2)'
  end

  def and_i_can_see_my_personal_details
    expect(page).to have_content 'Lando Calrissian'
    expect(page).to have_content '6 April 1937'
    expect(page).to have_content 'Belgian'
  end

  def and_i_can_see_my_efl_qualification
    expect(page).to have_content 'No, English is not a foreign language to me'
  end

  def when_i_confirm_my_application
    click_link 'Continue'
  end

  def when_i_choose_not_to_fill_in_the_equality_and_diversity_survey
    click_link 'Continue without completing questionnaire'
  end

  def when_i_choose_not_to_provide_further_information
    choose 'No'
  end

  def and_i_submit_the_application
    click_button 'Submit application'
  end

  def then_i_can_see_my_application_has_been_successfully_submitted
    expect(page).to have_content 'Application successfully submitted'
    expect(page).to have_content 'Your training provider will be in touch with you if they want to arrange an interview.'
  end
end

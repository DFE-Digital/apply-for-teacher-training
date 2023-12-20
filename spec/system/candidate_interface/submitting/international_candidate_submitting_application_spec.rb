require 'rails_helper'

RSpec.feature 'International candidate submits the application', skip: 'Update to continuous applications' do
  include CandidateHelper
  include EFLHelper

  it 'International candidate completes and submits an application' do
    given_i_am_signed_in

    when_i_have_completed_everything_except_the_efl_and_other_qualifications_section
    when_i_review_my_application
    then_i_should_see_the_efl_and_other_qualifications_section_is_incomplete
    when_i_confirm_my_application
    then_i_see_an_error_about_the_efl_and_other_qualifications_section

    when_i_complete_the_efl_section
    and_i_complete_the_other_qualifications_section
    then_i_should_see_all_sections_are_complete

    when_i_review_my_application
    then_i_can_see_my_course_choices
    and_i_can_see_my_personal_details
    and_i_can_see_my_efl_qualification

    when_i_confirm_my_application
    and_i_submit_the_application
    and_i_skip_feedback

    then_i_can_see_my_application_has_been_successfully_submitted
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_have_completed_everything_except_the_efl_and_other_qualifications_section
    # Consider moving some of this into CandidateHelper once International
    # feature flags have been removed, especially the efl_section.
    given_courses_exist
    visit candidate_interface_application_form_path

    click_link 'Choose your courses'
    candidate_fills_in_apply_again_course_choice

    # Basic personal details
    click_link t('page_titles.personal_information.heading')
    scope = 'application_form.personal_details'
    fill_in t('first_name.label', scope:), with: 'Lando'
    fill_in t('last_name.label', scope:), with: 'Calrissian'
    fill_in 'Day', with: '6'
    fill_in 'Month', with: '4'
    fill_in 'Year', with: '1937'
    click_button t('save_and_continue')

    # Nationality
    check 'Citizen of a different country'
    within all('.govuk-form-group')[1] do
      select 'Belgian'
    end
    click_button t('save_and_continue')

    # Right to work
    choose 'No'
    click_button t('save_and_continue')

    # Mark Personal Details complete
    choose t('application_form.completed_radio')
    click_button t('continue')

    click_link t('page_titles.contact_information')
    candidate_fills_in_international_contact_details

    click_link t('page_titles.work_history')
    candidate_fills_in_restructured_work_experience
    candidate_fills_in_restructured_work_experience_break

    click_link t('page_titles.volunteering.short')
    candidate_fills_in_restructured_volunteering_role

    click_link t('page_titles.training_with_a_disability')
    candidate_fills_in_disability_info

    click_link t('page_titles.suitability_to_work_with_children')
    candidate_fills_in_safeguarding_issues

    click_link t('page_titles.degree')
    candidate_fills_in_their_degree

    click_link 'Maths GCSE or equivalent'
    candidate_fills_in_their_maths_gcse

    click_link 'English GCSE or equivalent'
    candidate_fills_in_their_english_gcse

    click_link 'Science GCSE or equivalent'
    candidate_explains_a_missing_gcse

    click_link 'Why you want to teach'
    candidate_fills_in_becoming_a_teacher

    click_link 'Your suitability to teach a subject or age group'
    candidate_fills_in_subject_knowledge

    click_link t('page_titles.interview_preferences.heading')
    candidate_fills_in_interview_preferences

    click_link 'Equality and diversity questions'
    candidate_fills_in_diversity_information(school_meals: false)

    candidate_provides_two_referees
    receive_references
    mark_references_as_complete
  end

  def when_i_review_my_application
    click_link 'Check and submit your application'
  end

  def then_i_should_see_the_efl_and_other_qualifications_section_is_incomplete
    expect(page).to have_css "[data-qa='incomplete-efl']"
    expect(page).to have_css "[data-qa='incomplete-other_qualifications_international']"
  end

  def then_i_see_an_error_about_the_efl_and_other_qualifications_section
    within '#incomplete-efl-error' do
      expect(page).to have_content 'English as a foreign language not marked as complete'
    end

    within '#incomplete-other_qualifications_international-error' do
      expect(page).to have_content 'Other qualifications section not marked as complete'
    end
  end

  def when_i_complete_the_efl_section
    within '#incomplete-efl-error' do
      click_link 'Have you done an English as a foreign language assessment?'
    end

    choose 'No, English is not a foreign language to me'
    click_button t('continue')
    choose t('application_form.completed_radio')
    click_button t('continue')
  end

  def and_i_complete_the_other_qualifications_section
    click_link 'Other qualifications'
    candidate_fills_in_their_other_qualifications
  end

  def then_i_should_see_all_sections_are_complete
    application_form_sections.each do |section|
      expect(page).not_to have_selector "[data-qa='incomplete-#{section}']"
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
    click_link t('continue')
  end

  def and_i_submit_the_application
    click_button 'Send application'
  end

  def and_i_skip_feedback
    click_button 'Continue'
  end

  def then_i_can_see_my_application_has_been_successfully_submitted
    expect(page).to have_current_path candidate_interface_application_complete_path
    expect(page).to have_content 'Application submitted'
  end
end

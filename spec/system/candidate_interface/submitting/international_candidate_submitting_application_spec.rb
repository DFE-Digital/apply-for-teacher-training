require 'rails_helper'

RSpec.describe 'International candidate submits the application' do
  include CandidateHelper
  include EFLHelper

  before do
    FeatureFlag.activate(:candidate_preferences)
  end

  it 'International candidate completes and submits an application' do
    given_i_am_signed_in_with_one_login

    when_i_have_completed_everything_except_the_efl_and_other_qualifications_section
    when_i_review_my_details
    then_i_see_the_efl_and_other_qualifications_section_is_incomplete
    when_i_try_to_add_secondary_course
    then_i_see_a_warning_about_incomplete_details

    when_i_complete_the_efl_section
    and_i_complete_the_other_qualifications_section
    then_i_see_all_sections_are_complete

    when_i_review_my_choices
    then_i_can_see_my_course_choices

    when_i_review_my_application
    and_i_can_see_my_personal_details
    and_i_can_see_my_efl_qualification

    when_i_submit_my_application

    then_i_can_see_my_application_has_been_successfully_submitted
  end

  def when_i_submit_my_application
    click_link_or_button 'Confirm and submit application'
  end

  def when_i_have_completed_everything_except_the_efl_and_other_qualifications_section
    # Consider moving some of this into CandidateHelper once International
    # feature flags have been removed, especially the efl_section.
    given_courses_exist
    visit candidate_interface_details_path

    click_link_or_button t('page_titles.personal_information.heading')
    candidate_fills_in_personal_details(international: true)

    click_link_or_button t('page_titles.contact_information')
    candidate_fills_in_international_contact_details

    click_link_or_button t('page_titles.work_history')
    candidate_fills_in_restructured_work_experience
    candidate_fills_in_restructured_work_experience_break

    click_link_or_button t('page_titles.volunteering.short')
    candidate_fills_in_restructured_volunteering_role

    click_link_or_button t('page_titles.training_with_a_disability')
    candidate_fills_in_disability_info

    click_link_or_button t('page_titles.suitability_to_work_with_children')
    candidate_fills_in_safeguarding_issues

    click_link_or_button t('page_titles.degree')
    candidate_fills_in_their_degree

    click_link_or_button 'Maths GCSE or equivalent'
    candidate_fills_in_their_maths_gcse

    click_link_or_button 'English GCSE or equivalent'
    candidate_fills_in_their_english_gcse

    click_link_or_button 'Your personal statement'
    candidate_fills_in_personal_statement

    click_link_or_button t('page_titles.interview_preferences.heading')
    candidate_fills_in_interview_preferences

    click_link_or_button 'Equality and diversity questions'
    candidate_fills_in_diversity_information(school_meals: false)

    candidate_provides_two_referees
    receive_references
    mark_references_as_complete
  end

  def when_i_review_my_choices
    click_link_or_button 'Your applications'
  end

  def when_i_review_my_details
    click_link_or_button 'Your details'
  end

  def then_i_see_the_efl_and_other_qualifications_section_is_incomplete
    expect(page).to have_css('#english-as-a-foreign-language-assessment-badge-id', text: 'Incomplete')
    expect(page).to have_css('#other-qualifications-badge-id', text: 'Incomplete')
  end

  def then_i_see_a_warning_about_incomplete_details
    expect(page).to have_content 'You cannot submit this application until you complete your details.'
  end

  def when_i_complete_the_efl_section
    click_link_or_button 'complete your details'
    candidate_fills_in_efl_section
  end

  def and_i_complete_the_other_qualifications_section
    click_link_or_button 'Other qualifications'
    candidate_fills_in_their_other_qualifications
  end

  def then_i_see_all_sections_are_complete
    application_form_sections.each do |section|
      expect(page).to have_no_css "[data-qa='incomplete-#{section}']"
    end
  end

  def then_i_can_see_my_course_choices
    expect(page).to have_content 'Gorse SCITT'
    expect(page).to have_content 'Drama (2397)'
  end

  def and_i_can_see_my_personal_details
    expect(page).to have_content 'Lando Calrissian'
    expect(page).to have_content '6 April 1990'
    expect(page).to have_content 'Indian'
  end

  def and_i_can_see_my_efl_qualification
    expect(page).to have_content 'No, English is not a foreign language to me'
  end

  def when_i_try_to_add_secondary_course
    candidate_fills_in_secondary_course_choice_with_incomplete_details
  end

  def then_i_can_see_my_application_has_been_successfully_submitted
    expect(page).to have_current_path candidate_interface_share_details_path(submit_application: true)
    expect(page).to have_content 'Application submitted'
  end

  def when_i_review_my_application
    candidate_reviews_application
  end
end

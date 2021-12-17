require 'rails_helper'

RSpec.feature 'Candidate submits the application' do
  include CandidateHelper

  scenario 'Candidate with a completed application' do
    given_i_am_signed_in
    then_i_should_see_that_i_have_made_no_choices

    when_i_have_completed_my_application
    and_i_have_received_2_references
    and_i_review_my_application
    then_i_should_see_all_sections_are_complete
    and_i_can_see_my_course_choices
    and_i_can_see_my_personal_details
    and_i_can_see_my_contact_details
    and_i_can_see_my_disability_disclosure
    and_i_can_see_my_safeguarding_issues
    and_i_can_see_my_volunteering_roles
    and_i_can_see_my_degree
    and_i_can_see_my_gcses
    and_i_can_see_my_other_qualification
    and_i_can_see_my_becoming_a_teacher_info
    and_i_can_see_my_subject_knowlegde_info
    and_i_can_see_my_interview_preferences
    and_i_can_see_my_referees

    when_i_confirm_my_application
    and_i_fill_in_the_diversity_questions
    and_i_choose_to_add_further_information_but_omit_adding_details
    then_i_should_see_validation_errors

    when_i_fill_in_further_information
    and_i_submit_the_application
    and_i_skip_feedback
    then_i_can_see_my_application_has_been_successfully_submitted
    and_i_am_redirected_to_the_application_dashboard
    and_i_receive_an_email_confirmation

    when_i_click_view_application
    then_i_can_see_my_submitted_application
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def then_i_should_see_that_i_have_made_no_choices
    visit candidate_interface_application_form_path
    expect(page).to have_content(t('application_form.courses.intro'))
    visit candidate_interface_application_review_submitted_path
    expect(page).to have_content(t('application_form.courses.intro'))
    visit candidate_interface_application_complete_path
    expect(page).to have_content(t('application_form.courses.intro'))
  end

  def when_i_have_completed_my_application
    candidate_completes_application_form
  end

  def and_i_have_received_2_references
    @current_candidate.current_application.application_references.each do |reference|
      reference.update!(feedback_status: :feedback_provided)
    end
  end

  def and_i_review_my_application
    and_i_visit_the_application_form_page
    when_i_click_on_check_your_answers
  end

  def then_i_should_see_all_sections_are_complete
    application_form_sections.each do |section|
      expect(page).not_to have_selector "[data-qa='incomplete-#{section}']"
    end
  end

  def and_i_can_see_my_course_choices
    expect(page).to have_content 'Gorse SCITT'
    expect(page).to have_content 'Primary (2XT2)'
  end

  def and_i_can_see_my_personal_details
    expect(page).to have_content 'Lando Calrissian'
    expect(page).to have_content '6 April 1937'
    expect(page).to have_content 'British and American'
  end

  def and_i_can_see_my_contact_details
    expect(page).to have_content '07700 900 982'
    expect(page).to have_content '42 Much Wow Street'
    expect(page).to have_content 'London'
    expect(page).to have_content 'SW1P 3BT'
  end

  def and_i_can_see_my_disability_disclosure
    expect(page).to have_content 'Yes'
    expect(page).to have_content 'I have difficulty climbing stairs'
  end

  def and_i_can_see_my_safeguarding_issues
    expect(page).to have_content 'Yes'
    expect(page).to have_content 'I have a criminal conviction.'
  end

  def and_i_can_see_my_volunteering_roles
    expect(page).to have_content 'Tour guide'
    expect(page).to have_content 'National Trust'
  end

  def and_i_can_see_my_degree
    expect(page).to have_content 'BA (Hons) Doge'
    expect(page).to have_content 'University of Much Wow'
    expect(page).to have_content 'First class honours'
    expect(page).to have_content '2009'
  end

  def and_i_can_see_my_gcses
    expect(page).to have_content '1990'
  end

  def and_i_can_see_my_other_qualification
    expect(page).to have_content 'A level Believing in the Heart of the Cards'
    expect(page).to have_content 'A'
    expect(page).to have_content '2015'
  end

  def and_i_can_see_my_becoming_a_teacher_info
    expect(page).to have_content 'I believe I would be a first-rate teacher'
  end

  def and_i_can_see_my_subject_knowlegde_info
    expect(page).to have_content 'Everything'
  end

  def and_i_can_see_my_interview_preferences
    expect(page).to have_content 'Not on a Wednesday'
  end

  def and_i_can_see_my_referees
    within_summary_row('Selected references') do
      expect(page).to have_content 'Terri Tudor'
      expect(page).to have_content 'Anne Other'
    end
  end

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_check_your_answers
    click_link 'Check and submit your application'
  end

  def when_i_confirm_my_application
    click_link t('continue')
  end

  def and_i_fill_in_the_diversity_questions
    # intro page
    click_link t('continue')

    # What is your sex?
    choose 'Prefer not to say'
    click_button t('continue')

    # Are you disabled?
    choose 'Prefer not to say'
    click_button t('continue')

    # What is your ethnic group?
    choose 'Prefer not to say'
    click_button t('continue')

    # Review page
    click_link t('continue')
  end

  def and_i_choose_to_add_further_information_but_omit_adding_details
    choose 'Yes'
  end

  def then_i_should_see_validation_errors
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/further_information_form.attributes.further_information_details.blank')
  end

  def when_i_fill_in_further_information
    scope = 'application_form.further_information'
    fill_in t('further_information_details.label', scope: scope), with: "How you doin', ya old pirate? So good to see ya!", match: :prefer_exact
  end

  def and_i_submit_the_application
    click_button 'Send application'
  end

  def and_i_skip_feedback
    click_button 'Continue'
  end

  def then_i_can_see_my_application_has_been_successfully_submitted
    expect(page).to have_content 'Application successfully submitted'
    expect(page).to have_content 'You will get an email when something changes.'
  end

  def and_i_receive_an_email_confirmation
    open_email(current_candidate.email_address)
    expect(current_email).to have_content 'You have submitted an application'
    expect(current_email).to have_content 'Primary (2XT2) at Gorse SCITT'
  end

  def and_i_am_redirected_to_the_application_dashboard
    expect(page).to have_content t('page_titles.application_dashboard')
    expect(page).to have_content 'Gorse SCITT'
  end

  def when_i_click_view_application
    within '.app-summary-card__actions' do
      click_link 'View application'
    end
  end

  def then_i_can_see_my_submitted_application
    expect(page).to have_content t('page_titles.submitted_application')
    expect(page).to have_content Time.zone.now.to_s(:govuk_date)
    expect(page).to have_content 'Gorse SCITT'
    expect(page).to have_content 'Lando Calrissian'
    expect(page).to have_content '07700 900 982'
    expect(page).to have_content 'Tour guide'
    expect(page).to have_content 'BA (Hons) Doge'
    expect(page).to have_content 'A level Believing in the Heart of the Cards'
    expect(page).to have_content 'I believe I would be a first-rate teacher'
    expect(page).to have_content 'Everything'
    expect(page).to have_content 'Not on a Wednesday'
    expect(page).to have_content 'Terri Tudor'
  end
end

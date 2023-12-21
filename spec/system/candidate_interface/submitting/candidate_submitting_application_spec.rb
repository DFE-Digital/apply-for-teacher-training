require 'rails_helper'

RSpec.feature 'Candidate submits the application', skip: 'Update to continuous applications' do
  include CandidateHelper

  it 'Candidate with a completed application' do
    FeatureFlag.activate(:one_personal_statement)
    given_i_am_signed_in
    then_i_should_see_that_i_have_made_no_choices

    when_i_have_completed_my_application
    and_i_have_received_2_references
    and_i_review_my_application_details
    then_i_should_see_all_sections_are_complete

    and_i_can_see_my_personal_details
    and_i_can_see_my_contact_details
    and_i_can_see_my_disability_disclosure
    and_i_can_see_my_safeguarding_issues
    and_i_can_see_my_volunteering_roles
    and_i_can_see_my_degree
    and_i_can_see_my_gcses
    and_i_can_see_my_other_qualification
    and_i_can_see_my_personal_statement_info
    and_i_can_see_my_interview_preferences
    and_i_can_see_my_referees
    and_i_can_see_my_equality_and_diversity_answers

    and_i_visit_the_application_choices_page
    and_i_can_see_my_course_choices

    when_i_confirm_my_application
    and_i_submit_the_application
    then_i_can_see_my_application_has_been_successfully_submitted
    and_i_am_redirected_to_the_application_choices
    and_i_receive_an_email_confirmation

    when_i_click_view_application
    then_i_can_see_my_submitted_application
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def then_i_should_see_that_i_have_made_no_choices
    visit candidate_interface_continuous_applications_choices_path
    expect(page).to have_content(t('candidate_interface.applications_left_message.default_message', maximum_number_of_course_choices: 4))
  end

  def when_i_have_completed_my_application
    candidate_completes_application_form
  end

  def and_i_have_received_2_references
    @current_candidate.current_application.application_references.each do |reference|
      reference.update!(feedback_status: :feedback_provided)
    end
  end

  def and_i_review_my_application_details
    and_i_visit_the_application_details_page
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
    click_link 'Personal information'
    expect(page).to have_content 'Lando Calrissian'
    expect(page).to have_content '6 April 1990'
    expect(page).to have_content 'British and American'
    click_link 'Back to your details'
  end

  def and_i_can_see_my_contact_details
    click_link 'Contact information'
    expect(page).to have_content '07700 900 982'
    expect(page).to have_content '42 Much Wow Street'
    expect(page).to have_content 'London'
    expect(page).to have_content 'SW1P 3BT'
    click_link 'Back to your details'
  end

  def and_i_can_see_my_disability_disclosure
    click_link 'Ask for support if you’re disabled'
    expect(page).to have_content 'Yes'
    expect(page).to have_content 'I have difficulty climbing stairs'
    click_link 'Back to your details'
  end

  def and_i_can_see_my_safeguarding_issues
    click_link 'Declare any safeguarding issues'
    expect(page).to have_content 'Yes'
    expect(page).to have_content 'I have a criminal conviction.'
    click_link 'Back to your details'
  end

  def and_i_can_see_my_volunteering_roles
    click_link 'Unpaid experience'
    expect(page).to have_content 'Tour guide'
    expect(page).to have_content 'National Trust'
    click_link 'Back to your details'
  end

  def and_i_can_see_my_degree
    click_link 'Degree'
    expect(page).to have_content 'BA (Hons) Aerospace engineering'
    expect(page).to have_content 'ThinkSpace Education'
    expect(page).to have_content 'First-class honours'
    expect(page).to have_content '2009'
    click_link 'Back to your details'
  end

  def and_i_can_see_my_gcses
    click_link 'English GCSE or equivalent'
    expect(page).to have_content '1990'
    click_link 'Back to your details'
  end

  def and_i_can_see_my_other_qualification
    click_link 'A levels and other qualifications'
    expect(page).to have_content 'A level Believing in the Heart of the Cards'
    expect(page).to have_content 'A'
    expect(page).to have_content '2015'
    click_link 'Back to your details'
  end

  def and_i_can_see_my_personal_statement_info
    click_link 'Your personal statement'
    expect(page).to have_content 'I believe I would be a first-rate teacher'
    click_link 'Back to your details'
  end

  # def and_i_can_see_my_subject_knowlegde_info
  #   expect(page).to have_content 'Everything'
  #   click_link 'Back to your details'
  # end

  def and_i_can_see_my_interview_preferences
    click_link 'Interview availability'
    expect(page).to have_content 'Not on a Wednesday'
    click_link 'Back to your details'
  end

  def and_i_can_see_my_referees
    click_link 'References to be requested if you accept an offer'
    expect(page).to have_content('Terri Tudor')
    expect(page).to have_content('Anne Other')
    click_link 'Back to your details'
  end

  def and_i_can_see_my_equality_and_diversity_answers
    click_link 'Equality and diversity questions'
    expect(page).to have_content('Prefer not to say')
    click_link 'Back to your details'
  end

  def and_i_visit_the_application_details_page
    visit candidate_interface_continuous_applications_details_path
  end

  def and_i_visit_the_application_choices_page
    visit candidate_interface_continuous_applications_choices_path
  end

  def when_i_confirm_my_application
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
    fill_in t('further_information_details.label', scope:), with: "How you doin', ya old pirate? So good to see ya!", match: :prefer_exact
  end

  def and_i_submit_the_application
    click_button 'Review application'
    click_link 'Continue without editing'
    click_button 'Confirm and submit application'
  end

  def then_i_can_see_my_application_has_been_successfully_submitted
    expect(page).to have_content 'Application submitted'
  end

  def and_i_receive_an_email_confirmation
    open_email(current_candidate.email_address)
    expect(current_email).to have_content 'You’ve submitted an application'
    expect(current_email).to have_content 'Primary (2XT2) at Gorse SCITT'
  end

  def and_i_am_redirected_to_the_application_choices
    expect(page).to have_content t('page_titles.continuous_applications.your_applications')
    expect(page).to have_content 'Gorse SCITT'
  end

  def when_i_click_view_application
    within '.govuk-summary-card__title-wrapper' do
      click_link 'View application'
    end
  end

  def then_i_can_see_my_submitted_application
    expect(page).to have_current_path(candidate_interface_continuous_applications_course_review_path(ApplicationChoice.last.id))
    expect(page).to have_content 'Awaiting decision'
    expect(page).to have_content Time.zone.now.to_fs(:govuk_date)
    expect(page).to have_content 'Gorse SCITT'
    expect(page).to have_content 'Personal statement'
  end
end

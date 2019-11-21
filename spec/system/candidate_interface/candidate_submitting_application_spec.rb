require 'rails_helper'

RSpec.feature 'Candidate submit the application' do
  include CandidateHelper

  scenario 'Candidate with personal details and contact details' do
    given_i_am_signed_in
    and_i_have_completed_my_application

    and_reviewed_my_application
    and_i_confirm_my_application

    when_i_choose_to_add_further_information_but_omit_adding_details
    then_i_should_see_validation_errors

    when_i_fill_in_further_information
    and_i_can_submit_the_application

    then_i_can_see_my_application_has_been_successfully_submitted

    and_i_can_see_my_support_ref
    and_i_receive_an_email_with_my_support_ref
    and_my_referees_receive_a_request_for_a_reference_by_email

    when_i_click_on_track_your_application
    then_i_can_see_my_application_dashboard

    when_i_click_view_application
    then_i_can_see_my_submitted_application

    when_i_attempt_to_edit_my_personal_details
    then_i_can_see_my_application_dashboard

    when_i_attempt_to_edit_my_contact_details
    then_i_can_see_my_application_dashboard

    when_i_click_the_edit_application_link
    then_i_see_edit_information_page
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_have_completed_my_application
    candidate_completes_application_form
  end

  def and_i_have_chosen_a_course
    provider = create(:provider, name: 'Gorse SCITT', code: '1N1')
    site = create(:site, name: 'Main site', code: '-', provider: provider)
    course = create(:course, name: 'Primary', code: '2XT2', provider: provider, exposed_in_find: true)
    create(:course_option, site: site, course: course, vacancy_status: 'B')

    visit candidate_interface_application_form_path

    click_link 'Course choices'
    click_link 'Continue'
    choose 'Yes, I know where I want to apply'
    click_button 'Continue'
    choose 'Gorse SCITT (1N1)'
    click_button 'Continue'
    choose 'Primary (2XT2)'
    click_button 'Continue'
    choose 'Main site'
    click_button 'Continue'
  end

  def and_i_filled_in_personal_details
    visit candidate_interface_personal_details_edit_path
    candidate_fills_in_personal_details(scope: 'application_form.personal_details')

    click_button t('complete_form_button', scope: 'application_form.personal_details')
  end

  def when_i_attempt_to_edit_my_personal_details
    visit candidate_interface_personal_details_edit_path
  end

  def when_i_attempt_to_edit_my_contact_details
    visit candidate_interface_contact_details_edit_base_path
  end

  def and_i_filled_in_contact_details
    visit candidate_interface_contact_details_edit_base_path
    candidate_fills_in_contact_details

    click_button t('application_form.contact_details.address.button')
  end

  def and_i_gave_two_referees
    candidate_provides_two_referees
  end

  def and_reviewed_my_application
    and_i_visit_the_application_form_page
    when_i_click_on_check_your_answers
  end

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_check_your_answers
    click_link 'Check your answers before submitting'
  end

  def and_i_confirm_my_application
    click_link 'Continue'
  end

  def when_i_choose_to_add_further_information_but_omit_adding_details
    choose 'Yes'
  end

  def then_i_should_see_validation_errors
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/further_information_form.attributes.further_information_details.blank')
  end

  def when_i_fill_in_further_information
    scope = 'application_form.further_information'
    fill_in t('further_information_details.label', scope: scope), with: "How you doin', ya old pirate? So good to see ya!", match: :prefer_exact
  end

  def and_i_can_submit_the_application
    click_button 'Submit application'
  end

  def then_i_can_see_my_application_has_been_successfully_submitted
    expect(page).to have_content 'Application successfully submitted'
  end

  def and_i_can_see_my_support_ref
    support_ref = page.find('span#application-ref').text
    expect(support_ref).not_to be_empty
  end

  def and_i_receive_an_email_with_my_support_ref
    open_email(current_candidate.email_address)
    expect(current_email).to have_content 'Application submitted'
  end

  def and_my_referees_receive_a_request_for_a_reference_by_email
    current_application = current_candidate.current_application
    current_application.references.each do |reference|
      open_email(reference.email_address)
      expect(current_email).to have_content "Give a reference for #{current_application.first_name}"
      expect(current_email).to have_content reference.name
    end
  end

  def when_i_click_on_track_your_application
    click_link t('page_titles.application_dashboard')
  end

  def then_i_can_see_my_application_dashboard
    this_day = Time.now.strftime('%-e %B %Y')
    expect(page).to have_content t('page_titles.application_dashboard')
    expect(page).to have_content "Application submitted on #{this_day}"
    expect(page).to have_content 'Gorse SCITT'
    expect(page).to have_content current_candidate.current_application.references.first.name
    expect(page).to have_content 'Submitted'
  end

  def when_i_click_view_application
    click_link 'View application'
  end

  def then_i_can_see_my_submitted_application
    expect(page).to have_content t('page_titles.submitted_application')
    expect(page).to have_content Time.now.strftime('%-e %B %Y')
    expect(page).to have_content 'Gorse SCITT'
    expect(page).to have_content 'Lando Calrissian'
    expect(page).to have_content '07700 900 982'
    expect(page).to have_content 'Classroom Volunteer'
    expect(page).to have_content 'BA Doge'
    expect(page).to have_content 'A-Level Believing in the Heart of the Cards'
    expect(page).to have_content 'I WANT I WANT I WANT I WANT'
    expect(page).to have_content 'Everything'
    expect(page).to have_content 'NOT WEDNESDAY'
    expect(page).to have_content 'Terri Tudor'
  end

  def when_i_click_the_edit_application_link
    click_link 'Edit your application'
  end

  def then_i_see_edit_information_page
    expect(page).to have_content t('page_titles.application_edit')
  end
end

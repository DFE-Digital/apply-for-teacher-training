require 'rails_helper'

RSpec.feature 'Candidate reviews the answers' do
  include CandidateHelper

  scenario 'Candidate with personal details and contact details' do
    given_i_am_signed_in
    and_i_filled_in_personal_details
    and_i_filled_in_contact_details
    and_i_filled_in_degrees
    and_i_filled_in_other_qualifications
    and_i_visit_the_application_form_page

    when_i_click_on_check_your_answers

    then_i_can_review_my_application
    and_i_can_see_my_personal_details
    and_i_can_see_my_contact_details
    and_i_can_see_my_degree
    and_i_can_see_my_other_qualification
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_filled_in_personal_details
    visit candidate_interface_personal_details_edit_path
    candidate_fills_in_personal_details(scope: 'application_form.personal_details')

    click_button t('complete_form_button', scope: 'application_form.personal_details')
  end

  def and_i_filled_in_contact_details
    visit candidate_interface_contact_details_edit_base_path
    candidate_fills_in_contact_details

    click_button t('application_form.contact_details.address.button')
  end

  def and_i_filled_in_degrees
    visit candidate_interface_degrees_new_base_path
    candidate_fills_in_their_degree

    click_button t('application_form.degree.base.button')
  end

  def and_i_filled_in_other_qualifications
    visit candidate_interface_new_other_qualification_path
    candidate_fills_in_their_other_qualifications

    click_button t('application_form.other_qualification.base.button')
  end

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_check_your_answers
    click_link 'Check your answers before submitting'
  end

  def then_i_can_review_my_application
    expect(page).to have_content 'Review your application'
  end

  def and_i_can_see_my_personal_details
    expect(page).to have_content 'Lando Calrissian'
    expect(page).to have_content '6 April 1937'
    expect(page).to have_content 'British and American'
    expect(page).to have_content "I'm great at Galactic Basic so English is a piece of cake"
  end

  def and_i_can_see_my_contact_details
    expect(page).to have_content '07700 900 982'
    expect(page).to have_content '42 Much Wow Street'
    expect(page).to have_content 'London'
    expect(page).to have_content 'SW1P 3BT'
  end

  def and_i_can_see_my_degree
    expect(page).to have_content 'BA Doge'
    expect(page).to have_content 'University of Much Wow'
    expect(page).to have_content 'First'
    expect(page).to have_content '2009'
  end

  def and_i_can_see_my_other_qualification
    expect(page).to have_content 'A-Level Believing in the Heart of the Cards'
    expect(page).to have_content 'Yugi College'
    expect(page).to have_content 'A'
    expect(page).to have_content '2015'
  end
end

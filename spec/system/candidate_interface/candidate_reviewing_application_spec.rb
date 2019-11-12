require 'rails_helper'

RSpec.feature 'Candidate reviews the answers' do
  include CandidateHelper

  scenario 'Candidate with all sections filled in' do
    given_i_have_completed_my_application

    when_i_click_on_check_your_answers

    then_i_can_review_my_application
    and_i_can_see_my_personal_details
    and_i_can_see_my_contact_details
    and_i_can_see_my_volunteering_roles
    and_i_can_see_my_degree
    and_i_can_see_my_other_qualification
    and_i_can_see_my_disability_info
    and_i_can_see_my_becoming_a_teacher_info
    and_i_can_see_my_subject_knowlegde_info
    and_i_can_see_my_interview_preferences
    and_i_can_see_my_referees
  end

  def given_i_have_completed_my_application
    candidate_completes_application_form
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

  def and_i_can_see_my_volunteering_roles
    expect(page).to have_content 'Classroom Volunteer'
    expect(page).to have_content 'A Noice School'
    expect(page).to have_content 'I volunteered.'
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

  def and_i_can_see_my_disability_info
    expect(page).to have_content 'I have difficulty climbing stairs'
  end

  def and_i_can_see_my_becoming_a_teacher_info
    expect(page).to have_content 'I WANT I WANT I WANT I WANT'
  end

  def and_i_can_see_my_subject_knowlegde_info
    expect(page).to have_content 'Everything'
  end

  def and_i_can_see_my_interview_preferences
    expect(page).to have_content 'NOT WEDNESDAY'
  end

  def and_i_can_see_my_referees
    expect(page).to have_content 'Terri Tudor'
    expect(page).to have_content 'terri@example.com'
    expect(page).to have_content 'Tutor'

    expect(page).to have_content 'Anne Other'
    expect(page).to have_content 'anne@other.com'
    expect(page).to have_content 'First boss'
  end
end

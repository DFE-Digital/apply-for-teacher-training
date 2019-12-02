require 'rails_helper'

RSpec.feature 'Candidate reviews the answers' do
  include CandidateHelper

  scenario 'Candidate with all sections filled in' do
    given_courses_exist
    given_i_am_signed_in

    %i[
      course_choices
      personal_details
      contact_details
      work_experience
      volunteering
      degrees
      maths_gcse
      english_gcse
      science_gcse
      becoming_a_teacher
      subject_knowledge
      interview_preferences
      references
    ].map { |section| check_and_fill_in_section_for(section) }

    and_i_fill_in_other_qualifications

    when_i_review_my_application

    then_i_can_review_my_application
    then_i_can_see_my_course_choices
    and_i_can_see_my_personal_details
    and_i_can_see_my_contact_details
    and_i_can_see_my_volunteering_roles
    and_i_can_see_my_degree
    and_i_can_see_my_gcses
    and_i_can_see_my_other_qualification
    and_i_can_see_my_becoming_a_teacher_info
    and_i_can_see_my_subject_knowlegde_info
    and_i_can_see_my_interview_preferences
    and_i_can_see_my_referees
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_review_my_application
    and_i_visit_the_application_form_page
    when_i_click_on_check_your_answers
  end

  def and_i_fill_in_other_qualifications
    and_i_visit_the_application_form_page
    click_link 'Other relevant academic and non-academic qualifications'
    candidate_fills_in_their_other_qualifications
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

  def then_i_can_see_my_course_choices
    expect(page).to have_content 'Gorse SCITT'
    expect(page).to have_content 'Primary (2XT2)'
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

  def and_i_can_see_my_gcses
    expect(page).to have_content '1990'
  end

  def and_i_can_see_my_other_qualification
    expect(page).to have_content 'A-Level Believing in the Heart of the Cards'
    expect(page).to have_content 'Yugi College'
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
    expect(page).to have_content 'Terri Tudor'
    expect(page).to have_content 'terri@example.com'
    expect(page).to have_content 'Tutor'

    expect(page).to have_content 'Anne Other'
    expect(page).to have_content 'anne@other.com'
    expect(page).to have_content 'First boss'
  end

  def check_and_fill_in_section_for(section)
    when_i_review_my_application
    then_i_should_see_an_incomplete_banner_for(section)

    when_i_click_to_complete_section_for(section)
    then_i_should_be_able_to_complete_section_for(section)

    when_i_review_my_application
    then_i_should_not_see_an_incomplete_banner_for(section)
  end

  def then_i_should_see_an_incomplete_banner_for(section)
    expect(page).to have_content "Complete #{t("review_application.#{section}.complete_section_visually_hidden")} section"
  end

  def when_i_click_to_complete_section_for(section)
    click_link "Complete #{t("review_application.#{section}.complete_section_visually_hidden")} section"
  end

  def then_i_should_not_see_an_incomplete_banner_for(section)
    expect(page).not_to have_content "Complete #{t("review_application.#{section}.complete_section_visually_hidden")} section"
  end

  def then_i_should_be_able_to_complete_section_for(section)
    case section
    when :course_choices
      candidate_fills_in_course_choices
    when :personal_details
      candidate_fills_in_personal_details
    when :contact_details
      candidate_fills_in_contact_details
    when :work_experience
      candidate_fills_in_work_experience
    when :volunteering
      candidate_fills_in_volunteering_role
    when :degrees
      candidate_fills_in_their_degree
    when :becoming_a_teacher
      candidate_fills_in_becoming_a_teacher
    when :subject_knowledge
      candidate_fills_in_subject_knowledge
    when :interview_preferences
      candidate_fills_in_interview_preferences
    when :references
      candidate_provides_two_referees
    when :maths_gcse
      candidate_fills_in_a_gcse
    when :english_gcse
      candidate_fills_in_a_gcse
    when :science_gcse
      candidate_fills_in_a_gcse
    else
      raise "Unimplemented section #{section}"
    end
  end
end

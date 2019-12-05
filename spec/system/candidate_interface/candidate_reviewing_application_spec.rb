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
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_review_my_application
    and_i_visit_the_application_form_page
    when_i_click_on_check_your_answers
  end

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_check_your_answers
    click_link 'Check your answers before submitting'
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
    expect(page).to have_selector "[aria-describedby='missing-#{section}']"
  end

  def when_i_click_to_complete_section_for(section)
    within "#missing-#{section}-error" do
      click_link 'Complete section'
    end
  end

  def then_i_should_not_see_an_incomplete_banner_for(section)
    expect(page).not_to have_selector "[aria-describedby='missing-#{section}']"
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

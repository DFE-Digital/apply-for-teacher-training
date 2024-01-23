require 'rails_helper'

RSpec.feature 'Candidate submits the application', :continuous_applications do
  include CandidateHelper

  scenario 'Candidate with incomplete application seeing the error message' do
    given_i_am_signed_in

    and_i_have_incomplete_sections_on_my_personal_statement
    and_i_have_a_primary_and_secondary_application_choice
    when_i_go_to_secondary_review_page
    then_i_should_be_seeing_an_error_message
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_have_incomplete_sections_on_my_personal_statement
    current_candidate.application_forms.delete_all
    current_candidate.application_forms << build(:application_form, :minimum_info, submitted_at: nil, becoming_a_teacher: 'I want to teach')
  end

  def and_i_have_a_primary_and_secondary_application_choice
    secondary = create(:course, :with_course_options, :open_on_apply, :secondary, funding_type: 'fee', can_sponsor_student_visa: true)
    primary = create(:course, :with_course_options, :open_on_apply, :primary, funding_type: 'fee', can_sponsor_student_visa: true)

    secondary_course_option = create(:course_option, course: secondary)
    primary_course_option = create(:course_option, course: primary)

    @secondary_application_choice = create(:application_choice, :unsubmitted, course_option: secondary_course_option, application_form: current_candidate.current_application)
    @primary_application_choice = create(:application_choice, :unsubmitted, course_option: primary_course_option, application_form: current_candidate.current_application)
  end

  def when_i_go_to_secondary_review_page
    visit candidate_interface_continuous_applications_course_review_path(@secondary_application_choice)
  end

  def then_i_should_be_seeing_an_error_message
    expect(page).to have_content('You cannot submit this application until you complete your details.')
  end
end

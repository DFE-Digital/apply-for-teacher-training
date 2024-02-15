require 'rails_helper'

RSpec.feature 'Candidate viewing booked interviews' do
  include CandidateHelper

  scenario 'Candidate has submitted their application and has interview slots booked' do
    given_i_am_signed_in
    and_i_have_interviews_booked
    when_i_visit_application_choices_list
    and_i_click_to_view_my_application
    then_i_can_see_details_about_my_booked_interviews
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_have_interviews_booked
    create(:completed_application_form, candidate: @current_candidate, submitted_application_choices_count: 1)
    @application_choice = @current_candidate.current_application.application_choices.first
    create(:interview, location: 'interview 1', application_choice: @application_choice)
    create(:interview, location: 'interview 2', application_choice: @application_choice)
  end

  def then_i_can_see_details_about_my_booked_interviews
    expect(page).to have_content 'interview 1'
    expect(page).to have_content 'interview 2'
  end
end

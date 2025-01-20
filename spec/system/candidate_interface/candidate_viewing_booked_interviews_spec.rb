require 'rails_helper'

RSpec.describe 'Candidate viewing booked interviews' do
  include CandidateHelper

  scenario 'Candidate has submitted their application and has interview slots booked' do
    given_i_am_signed_in_with_one_login
    and_i_have_interviews_booked
    and_i_have_interviews_cancelled
    when_i_visit_my_applications
    and_i_click_to_view_my_application
    then_i_can_see_details_about_my_booked_interviews
    and_i_can_not_see_the_cancelled_interviews
  end

  def and_i_have_interviews_booked
    application_form = create(:application_form, :completed, candidate: current_candidate)
    @application_choice = create(:application_choice, :interviewing, application_form:)
    create(:interview, location: 'interview 1', application_choice: @application_choice)
    create(:interview, location: 'interview 2', application_choice: @application_choice)
  end

  def and_i_have_interviews_cancelled
    create(:interview, :cancelled, location: cancelled_location, application_choice: @application_choice)
  end

  def then_i_can_see_details_about_my_booked_interviews
    expect(page).to have_content 'Information from provider:'
    expect(page).to have_content 'interview 1'
    expect(page).to have_content 'interview 2'
  end

  def and_i_can_not_see_the_cancelled_interviews
    expect(page).to have_no_content cancelled_location
  end

  def cancelled_location
    'this is cancelled!'
  end
end

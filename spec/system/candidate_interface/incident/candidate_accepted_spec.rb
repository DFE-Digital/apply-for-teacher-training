require 'rails_helper'

RSpec.feature 'Candidate signs in and prefills application in Sandbox', :sandbox do
  include SignInHelper
  include CandidateHelper

  scenario 'User with incident id is not signed out again' do
    given_i_am_a_candidate_with_a_rejected_id
    and_i_last_signed_in_after_the_incident

    when_i_am_signed_in
    and_i_visit_my_application_page
    then_i_am_on_the_my_details_page
  end

  def given_i_am_a_candidate_with_a_rejected_id
    @candidate = create(:candidate, id: 1)
    @application_form = create(:application_form, candidate: @candidate)
  end

  def and_i_last_signed_in_after_the_incident
    @candidate.last_signed_in_at = Time.new(2024, 3, 7, 12, 0)
  end

  def when_i_am_signed_in
    login_as @candidate
  end

  def and_i_visit_my_application_page
    visit candidate_interface_continuous_applications_details_path
  end

  def then_i_am_on_the_my_details_page
    expect(page).to have_current_path(candidate_interface_continuous_applications_details_path)
  end
end

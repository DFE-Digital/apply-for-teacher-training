require 'rails_helper'

RSpec.feature 'Candidate signs in and prefills application in Sandbox', :sandbox do
  include SignInHelper
  include CandidateHelper

  scenario 'User is directed to prefill option page and chooses to prefill the application' do
    and_a_course_is_available
    and_i_am_a_candidate_with_a_rejected_id
    and_i_last_signed_in_before_the_incident

    when_i_am_signed_in
    then_i_am_logged_out_and_redirected
  end

  def and_a_course_is_available
    @course_option = create(:course_option, course: create(:course, :open_on_apply, recruitment_cycle_year: RecruitmentCycle.current_year))
  end

  def and_i_am_a_candidate_with_a_rejected_id
    @candidate = create(:candidate, id: 1)
    @application_form = create(:application_form, candidate: @candidate)
  end

  def and_i_last_signed_in_before_the_incident
    @candidate.last_signed_in_at = Time.new(2024, 3, 4, 12, 0)
  end

  def when_i_am_signed_in
    visit candidate_interface_sign_in_path
    login_as @candidate
  end

  def and_i_click_on_the_link_in_my_email_and_sign_in
    open_email(@candidate.email_address)
    click_magic_link_in_email
    confirm_sign_in
  end

  def then_i_am_logged_out_and_redirected
    expect(page).to have_current_path(candidate_interface_sign_in_path)
  end
end

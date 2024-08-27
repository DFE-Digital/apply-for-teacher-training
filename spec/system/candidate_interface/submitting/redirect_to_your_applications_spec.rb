require 'rails_helper'

RSpec.describe 'Candidate submission' do
  include CandidateHelper

  scenario 'when candidate submitted at least once' do
    given_i_have_a_submitted_application
    when_i_sign_in
    then_i_am_on_your_applications_page
  end

  scenario 'when candidate has a draft application' do
    given_i_have_a_draft_application
    when_i_sign_in
    then_i_am_on_your_applications_page
  end

  scenario 'when candidate has no applications' do
    given_i_have_in_progress_application_form
    when_i_sign_in
    then_i_am_on_your_details_page
  end

  def given_i_have_a_submitted_application
    create(
      :application_choice,
      :awaiting_provider_decision,
      application_form:,
    )
  end

  def given_i_have_a_draft_application
    create(
      :application_choice,
      :unsubmitted,
      application_form:,
    )
  end

  def when_i_sign_in
    login_as(current_candidate)
    visit root_path
  end

  def then_i_am_on_your_applications_page
    expect(page).to have_current_path candidate_interface_continuous_applications_choices_path
  end

  def given_i_have_in_progress_application_form
    application_form
  end

  def application_form
    create(
      :completed_application_form,
      submitted_at: Time.zone.now,
      candidate: current_candidate,
      recruitment_cycle_year: 2024,
    )
  end
end

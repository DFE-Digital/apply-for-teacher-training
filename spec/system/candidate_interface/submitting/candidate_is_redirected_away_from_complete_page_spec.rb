require 'rails_helper'

RSpec.describe 'Redirects away from complete page' do
  include CandidateHelper

  scenario 'Candidate with an application', time: mid_cycle do
    ApplicationChoice.statuses.each_value do |status|
      @status = status
      @candidate = create(:candidate)

      given_i_am_signed_in
      and_i_have_an_application_choice
      when_i_visit_the_application_complete_page
      then_i_am_redirected_away_from_complete_page
    end
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate(candidate: @candidate)
  end

  def and_i_have_an_application_choice
    application_form = create(:application_form, :completed, :submitted, candidate: @candidate)
    create(:application_choice, @status, application_form:)
  end

  def then_i_am_redirected_away_from_complete_page
    expect(page).to have_current_path(expected_path)
  end

  def expected_path
    case @status.to_sym
    when :unsubmitted, :cancelled, :awaiting_provider_decision, :inactive, :interviewing, :application_not_sent, :offer_withdrawn, :declined, :withdrawn, :conditions_not_met, :offer, :rejected
      candidate_interface_continuous_applications_details_path
    when :pending_conditions, :offer_deferred, :recruited
      candidate_interface_application_offer_dashboard_path
    end
  end
end

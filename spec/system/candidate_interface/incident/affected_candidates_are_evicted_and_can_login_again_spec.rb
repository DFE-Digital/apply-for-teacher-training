require 'rails_helper'
require_relative 'incident_helper'

RSpec.feature 'User gets logged out and can immediately log back in' do
  include SignInHelper
  include CandidateHelper
  include IncidentHelper

  context 'when environment variable is set', :with_audited do
    scenario 'Affected candidates are signed out and can log back in' do
      given_i_am_a_candidate_with_a_rejected_id

      when_i_am_signed_in
      and_i_visit_my_details
      then_i_am_on_the_my_details_page

      FeatureFlag.activate(:incident_eviction)
      TestSuiteTimeMachine.advance_time_by(1.second)

      and_i_visit_my_details
      then_i_am_logged_out_and_redirected_sign_in_or_sign_up

      and_i_log_in_with_email
      and_i_visit_my_details
      then_i_am_on_the_my_details_page

      and_i_visit_my_applications
      then_i_am_on_the_my_applications_page
    end
  end
end

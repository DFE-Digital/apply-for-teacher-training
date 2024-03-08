require 'rails_helper'
require_relative 'incident_helper'

RSpec.feature 'User gets logged out and can immediately log back in' do
  include SignInHelper
  include CandidateHelper
  include IncidentHelper

  context 'when environment variable is set' do
    before do
      ENV['INCIDENT_240306_FIX_DEPLOYMENT_TIME'] = 3.days.from_now.to_fs(:iso8601)
    end

    scenario 'Affected candidates are signed out and can log back in' do
      given_i_am_a_candidate_with_a_rejected_id

      when_i_am_signed_in
      and_i_visit_my_details
      then_i_am_on_the_my_details_page

      TestSuiteTimeMachine.advance_time_by(4.days)

      and_i_visit_my_details
      then_i_am_logged_out_and_redirected_sign_in_or_sign_up

      and_i_log_in_with_email
      and_i_visit_my_details
      then_i_am_on_the_my_details_page

      and_i_visit_my_applications
      then_i_am_on_the_my_applications_page
    end
  end

  context 'when the environment variable is not set' do
    before do
      ENV['INCIDENT_240306_FIX_DEPLOYMENT_TIME'] = nil
    end

    scenario 'Affected candidates are signed out and can log back in', time: Time.zone.local(2024, 3, 11, 14) - 1.day do
      given_i_am_a_candidate_with_a_rejected_id

      when_i_am_signed_in
      and_i_visit_my_details
      then_i_am_on_the_my_details_page

      TestSuiteTimeMachine.advance_time_by(2.days)

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

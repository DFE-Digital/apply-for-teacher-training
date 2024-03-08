require 'rails_helper'
require_relative 'incident_helper'

RSpec.feature 'Logged out immediately' do
  include SignInHelper
  include CandidateHelper
  include IncidentHelper


  # Now is before the deploy date
  scenario 'The candidate cookie is rejected', time: IncidentHelper::ORIGINAL_LOGIN_DATE do
    given_i_am_a_candidate_with_a_rejected_id

    # This happens on the Ghost DB
    when_i_am_signed_in
    and_i_visit_my_details
    then_i_am_logged_out_and_redirected_to_create_an_account

    # 11/3/2024
    less_than_one_week_passes
    and_i_visit_my_details
    then_i_am_logged_out_and_redirected_to_sign_in

    and_i_log_in_with_email
    and_i_visit_my_details
    then_i_am_on_the_my_details_page
  end

  def less_than_one_week_passes
    time = 1.week - 1.hour
    TestSuiteTimeMachine.advance_time_to(time.from_now)
  end
end

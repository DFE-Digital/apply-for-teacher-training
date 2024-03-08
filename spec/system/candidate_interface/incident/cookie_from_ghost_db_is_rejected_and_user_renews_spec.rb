require 'rails_helper'
require_relative 'incident_helper'

RSpec.feature 'User gets logged out immediately can log back in' do
  include SignInHelper
  include CandidateHelper
  include IncidentHelper

  scenario '1 week since last request', time: Time.zone.local(2024, 3, 4) do
    given_i_am_a_candidate_with_a_rejected_id
    and_i_last_signed_in_before_the_incident
    create_session
    # This happens on the Ghost DB
    when_i_am_signed_in
    and_i_visit_my_details
    then_i_am_logged_out_and_redirected_to_create_an_account

    # 11/3/2024
    when_one_week_passes
    and_i_visit_my_details
    then_i_am_logged_out_and_redirected_to_sign_in

    and_i_log_in_with_email
    and_i_visit_my_details
    then_i_am_on_the_my_details_page
  end

  def create_session
    # app = ->(_env) { [200, { 'content-type' => 'text/plain' }, ['All responses are OK']] }
    visit '/'
    # binding.pry
    # session = Rack::MockSession.new(app).env['rack.session']
    # page.driver.browser.instance_variable_set(:@_rack_test_sessions, { default:  })
    page.driver.browser.instance_variable_get(:@_rack_test_sessions).first.second.last_request.env['rack.session']['warden.user.candidate.session'] = { 'last_request_at' => 3.days.ago.to_i }
  end
end

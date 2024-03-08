module IncidentHelper
  ORIGINAL_LOGIN_DATE = Time.zone.local(2024, 3, 7)

  DEPLOY_DATE = Time.zone.local(2024, 3, 11, 12)

  def when_i_am_signed_in
    login_as @candidate
    # page.driver.browser.instance_variable_get(:@_rack_test_sessions).first.second.last_request.env['rack.session']['warden.user.candidate.session']['last_request_at'] = 3.days.ago.to_i
  end

  def given_i_am_a_candidate_with_a_rejected_id
    @candidate = create(:candidate, id: 1)
    create(:application_form, candidate: @candidate)
  end

  def and_i_log_in_with_email
    and_i_go_to_sign_in(candidate: @candidate)
  end

  def and_i_visit_my_details
    visit candidate_interface_sign_in_path
  end

  def then_i_am_on_the_my_details_page
    expect(page).to have_current_path(candidate_interface_continuous_applications_details_path)
  end

  def then_i_am_logged_out_and_redirected_to_sign_in
    expect(page).to have_current_path(candidate_interface_sign_in_path)
  end

  def then_i_am_logged_out_and_redirected_to_create_an_account
    expect(page).to have_current_path(candidate_interface_create_account_or_sign_in_path)
  end

  def when_one_week_passes
    time = 1.week + 1.hour
    TestSuiteTimeMachine.advance_time_to(time.from_now)
  end
end

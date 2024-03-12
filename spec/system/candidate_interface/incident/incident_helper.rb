module IncidentHelper
  def when_i_am_signed_in
    login_as @candidate
  end

  def given_i_am_a_candidate_with_a_rejected_id
    @candidate = create(:candidate, id: 1)
    create(:application_form, candidate: @candidate)
  end

  def and_i_log_in_with_email
    and_i_go_to_sign_in(candidate: @candidate)
  end

  def and_i_visit_my_details
    visit candidate_interface_continuous_applications_details_path
  end

  def then_i_am_on_the_my_details_page
    expect(page).to have_current_path(candidate_interface_continuous_applications_details_path)
  end

  def and_i_visit_my_applications
    visit candidate_interface_continuous_applications_choices_path
  end

  def then_i_am_on_the_my_applications_page
    expect(page).to have_current_path(candidate_interface_continuous_applications_choices_path)
  end

  def then_i_am_logged_out_and_redirected_to_sign_in
    expect(page).to have_current_path(candidate_interface_sign_in_path)
  end

  def then_i_am_logged_out_and_redirected_sign_in_or_sign_up
    expect(page).to have_current_path(candidate_interface_create_account_or_sign_in_path)
  end

  def and_the_feature_flag_is_activated
    FeatureFlag.activate(:incident_eviction)
    TestSuiteTimeMachine.advance
  end

  def and_the_feature_flag_is_deactivated
    FeatureFlag.deactivate(:incident_eviction)
  end
end

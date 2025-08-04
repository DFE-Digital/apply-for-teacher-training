require 'rails_helper'

RSpec.describe "withdrawing an application at the candidate's request" do
  include DfESignInHelpers
  include CourseOptionHelpers

  before do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_make_decisions_for_my_provider
  end

  scenario 'A provider user withdraws an application at the request of a candidate' do
    and_my_organisation_has_received_an_application_with_an_interview
    and_i_sign_in_to_the_provider_interface

    when_i_visit_a_submitted_application
    and_i_click_a_link_to_withdraw_at_candidates_request
    then_i_see_the_interview_cancellation_explanation

    when_i_confirm_the_withdrawal
    then_i_see_a_message_confirming_that_the_application_has_been_withdrawn
    and_i_can_no_longer_see_the_withdraw_at_candidates_request_link
    and_the_candidate_receives_an_email_about_the_withdrawal
    and_the_interview_has_been_cancelled

    when_i_visit_the_decline_or_withdraw_page
    then_i_get_redirected_to_the_application_choice
  end

  scenario 'A provider user can withdraw an inactive application' do
    and_my_organisation_has_received_an_inactive_application_with_an_interview
    and_i_sign_in_to_the_provider_interface

    when_i_visit_a_submitted_application
    and_i_click_a_link_to_withdraw_at_candidates_request
    then_i_see_the_interview_cancellation_explanation
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_make_decisions_for_my_provider
    @provider = create(:provider)
    @provider_user = create(:provider_user, :with_make_decisions, providers: [@provider], dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
  end

  def and_my_organisation_has_received_an_application_with_an_interview
    course_option = course_option_for_provider_code(provider_code: @provider.code)
    @application_choice = create(:application_choice, :awaiting_provider_decision, :with_completed_application_form, course_option:)
    @interview = create(:interview, application_choice: @application_choice)
  end

  def and_my_organisation_has_received_an_inactive_application_with_an_interview
    course_option = course_option_for_provider_code(provider_code: @provider.code)
    @application_choice = create(:application_choice, :inactive, course_option:)
    @interview = create(:interview, application_choice: @application_choice)
  end

  def and_i_sign_in_to_the_provider_interface
    provider_signs_in_using_dfe_sign_in
  end

  def when_i_visit_a_submitted_application
    visit provider_interface_application_choice_path(@application_choice)
  end

  def and_i_click_a_link_to_withdraw_at_candidates_request
    click_link_or_button 'Withdraw at candidate’s request'
  end

  def then_i_see_the_interview_cancellation_explanation
    expect(page).to have_content('The upcoming interview will be cancelled.')
  end

  def when_i_confirm_the_withdrawal
    expect(page).to have_content('Confirm that the candidate wants to withdraw their application')

    click_link_or_button 'Withdraw application'
  end

  def then_i_see_a_message_confirming_that_the_application_has_been_withdrawn
    expect(page).to have_current_path(provider_interface_application_choice_path(@application_choice))
    expect(page).to have_content('Application withdrawn')
  end
  alias_method :then_i_get_redirected_to_the_application_choice, :then_i_see_a_message_confirming_that_the_application_has_been_withdrawn

  def and_i_can_no_longer_see_the_withdraw_at_candidates_request_link
    expect(page).to have_no_link 'Withdraw at candidate’s request'
  end

  def and_the_candidate_receives_an_email_about_the_withdrawal
    open_email(@application_choice.application_form.candidate.email_address)
    expect(current_email.subject).to have_content 'Update on your application'
  end

  def and_the_interview_has_been_cancelled
    expect(@interview.reload.cancelled_at).not_to be_nil
  end

  def when_i_visit_the_decline_or_withdraw_page
    visit provider_interface_decline_or_withdraw_edit_path(@application_choice)
  end
end

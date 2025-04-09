require 'rails_helper'

RSpec.describe 'Unlinking candidate one login', :with_audited do
  include DfESignInHelpers

  scenario 'unlinking where account recovery has taken place' do
    given_i_am_a_support_user
    and_a_candidate_with_a_one_login_auth_account_and_account_recovery_request_exist
    when_i_visit_the_application_form_summary
    and_i_click_on('Change candidate GOV.UK One Login')
    then_i_see_the_unlink_form

    when_i_add_an_audit_comment
    and_i_click_on('Continue')
    i_see_the_success_message
    and_the_one_login_auth_record_is_deleted
    and_the_account_recovery_request_is_deleted
    and_the_audit_has_been_logged
  end

  scenario 'unlinking where there has been no account recovery' do
    given_i_am_a_support_user
    and_a_candidate_with_a_one_login_auth_account_and_no_account_recovery_request
    when_i_visit_the_application_form_summary
    and_i_click_on('Change candidate GOV.UK One Login')
    then_i_see_the_unlink_form

    when_i_add_an_audit_comment
    and_i_click_on('Continue')
    i_see_the_success_message
    and_the_one_login_auth_record_is_deleted
    and_the_audit_has_been_logged
  end

  scenario 'navigation' do
    given_i_am_a_support_user
    and_a_candidate_with_a_one_login_auth_account_and_no_account_recovery_request
    when_i_visit_the_application_form_summary
    and_i_click_on('Change candidate GOV.UK One Login')
    then_i_see_the_unlink_form
    when_i_click_on('Back')
    then_i_am_on_the_application_form_summary

    and_i_click_on('Change candidate GOV.UK One Login')
    and_i_click_on('Cancel')
    then_i_am_on_the_application_form_summary
  end

  scenario 'errors' do
    given_i_am_a_support_user
    and_a_candidate_with_a_one_login_auth_account_and_no_account_recovery_request
    when_i_visit_the_application_form_summary
    and_i_click_on('Change candidate GOV.UK One Login')

    and_i_click_on('Continue')
    then_i_see_the_error_message('Enter a comment for the audit log')

    when_i_enter_a_very_long_audit_log_comment
    and_i_click_on('Continue')
    then_i_see_the_error_message('Audit log comment should be fewer than 200 words')
  end

private

  def and_i_click_on(string)
    click_on string
  end
  alias_method :when_i_click_on, :and_i_click_on

  def then_i_see_the_error_message(message)
    expect(page).to have_content(message).twice
  end

  def when_i_enter_a_very_long_audit_log_comment
    fill_in 'Audit log comment', with: 'hi there ' * 101
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_a_candidate_with_a_one_login_auth_account_and_account_recovery_request_exist
    @application_form = create(:application_form)
    @candidate = @application_form.candidate
    @candidate.update(account_recovery_status: 'recovered')

    create(:one_login_auth, candidate: @candidate)
    create(:account_recovery_request, candidate: @candidate)
  end

  def and_a_candidate_with_a_one_login_auth_account_and_no_account_recovery_request
    @application_form = create(:application_form)
    @candidate = @application_form.candidate

    create(:one_login_auth, candidate: @candidate)
  end

  def when_i_visit_the_application_form_summary
    visit support_interface_application_form_path(@application_form)
  end

  def then_i_see_the_unlink_form
    expect(page).to have_content "Do you want to unlink GOV.UK One Login for #{@candidate.email_address}"
  end

  def then_i_am_on_the_application_form_summary
    expect(page).to have_current_path support_interface_application_form_path(@application_form), ignore_query: true
  end

  def when_i_add_an_audit_comment
    fill_in 'Audit log comment', with: 'This is a comment about one login auth'
  end

  def i_see_the_success_message
    expect(page).to have_content 'GOV.UK One Login has been unlinked'
  end

  def and_the_one_login_auth_record_is_deleted
    @candidate.reload
    expect(@candidate.one_login_auth).to be_nil
  end

  def and_the_account_recovery_request_is_deleted
    expect(@candidate.account_recovery_request).to be_nil
    expect(@candidate.account_recovery_status).to eq 'not_started'
  end

  def and_the_audit_has_been_logged
    expect(@candidate.audits.last.comment).to eq 'This is a comment about one login auth'
  end
end

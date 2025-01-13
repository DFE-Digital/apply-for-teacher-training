require 'rails_helper'

RSpec.describe 'Candidate recovers their account' do
  include OneLoginHelper

  before do
    given_the_one_login_feature_flag_is_active
  end

  scenario 'Candidate recovers their account successfully' do
    given_i_have_a_candidate_record
    given_i_have_an_old_account
    given_i_am_signed_in
    when_i_visit_the_candidate_application_path

    when_i_click('Get your details back')
    then_i_am_redirected_to_recover_account_request_page
    when_i_input_the_email_address_i_want_to_recover
    when_i_click('Send email')
    then_i_am_redirected_to_recover_account_page
    and_i_receive_my_recover_email

    when_i_input_my_recovery_code
    when_i_click('Continue')
    then_i_redirected_to_the_candidate_application_path
    and_i_see_a_success_message
    and_i_signed_in_as_my_old_account
  end

  scenario 'Candidate recovers requests another code' do
    given_i_have_a_candidate_record
    given_i_have_an_old_account
    given_i_am_signed_in
    when_i_visit_the_candidate_application_path

    when_i_click('Get your details back')
    then_i_am_redirected_to_recover_account_request_page
    when_i_input_the_email_address_i_want_to_recover
    when_i_click('Send email')
    then_i_am_redirected_to_recover_account_page
    and_i_receive_my_recover_email

    when_i_click('Request a new code')
    then_i_am_redirected_to_recover_account_page
    and_i_receive_my_recover_email
    when_i_input_my_recovery_code

    when_i_click('Continue')
    then_i_redirected_to_the_candidate_application_path
    and_i_see_a_success_message
    and_i_signed_in_as_my_old_account
  end

  scenario 'Candidate dismisses the account recovery banner' do
    given_i_have_a_candidate_record
    given_i_have_an_old_account
    given_i_am_signed_in
    when_i_visit_the_candidate_application_path

    when_i_click('close this message')
    then_i_dont_see_the_account_recovery_banner
  end

  def given_the_one_login_feature_flag_is_active
    FeatureFlag.activate(:one_login_candidate_sign_in)
  end

  def given_i_have_a_candidate_record
    @candidate = create(:candidate)
  end

  def given_i_have_an_old_account
    @old_candidate = create(:candidate)
  end

  def given_i_am_signed_in
    sign_in_with_one_login(@candidate.email_address)
  end

  def given_i_have_one_login_account(email_address)
    user_exists_in_one_login(email_address:)
  end

  def when_i_visit_the_candidate_application_path
    visit candidate_interface_details_path
  end

  def when_i_click(button)
    click_link_or_button button
  end

  def then_i_am_redirected_to_recover_account_request_page
    expect(page).to have_current_path(
      new_candidate_interface_account_recovery_request_path,
    )
  end

  def when_i_input_the_email_address_i_want_to_recover
    fill_in(
      'candidate-interface-account-recovery-request-form-previous-account-email-address-field',
      with: @old_candidate.email_address,
    )
  end

  def then_i_am_redirected_to_recover_account_page
    expect(page).to have_current_path(
      candidate_interface_account_recovery_new_path,
    )
  end

  def and_i_receive_my_recover_email
    open_email(@old_candidate.email_address)
    @recovery_code = current_email.body.scan(/\^(?<number>\d+)/).flatten.first
    expect(current_email.subject).to eq(
      '[TEST] Your recovery code to sign in to Apply for teacher training',
    )
  end

  def when_i_input_my_recovery_code
    fill_in(
      'candidate-interface-account-recovery-form-code-field',
      with: @recovery_code,
    )
  end

  def then_i_redirected_to_the_candidate_application_path
    expect(page).to have_current_path(candidate_interface_details_path)
  end

  def and_i_see_a_success_message
    expect(page).to have_content(
      'You have connected your Apply for teacher training profile to the email address you use for GOV.UK One Login. ' \
      'You should use your GOV.UK One Login email address to sign into Apply for teacher training in future.',
    )
  end

  def and_i_signed_in_as_my_old_account
    expect(Candidate.count).to eq(1)
    expect(Candidate.first).to eq(@old_candidate)
  end

  def then_i_dont_see_the_account_recovery_banner
    expect(page).to have_no_content('Get your details back')
  end
end

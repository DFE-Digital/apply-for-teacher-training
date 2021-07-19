require 'rails_helper'

RSpec.feature 'Candidate tries to sign up using magic link with an invalid token' do
  include SignInHelper

  scenario 'Candidate signs in and receives an email inviting them to sign up' do
    given_the_pilot_is_open
    given_i_am_a_candidate_without_an_account

    when_i_go_to_sign_up
    and_i_submit_my_email_address
    then_i_receive_an_email_inviting_me_to_sign_up

    when_the_magic_link_token_is_expired
    and_i_click_on_the_link_in_my_email
    then_i_am_taken_to_the_expired_link_page

    when_i_click_the_button_to_send_me_a_sign_in_email
    then_i_receive_an_email_inviting_me_to_sign_in
    and_i_click_on_the_link_in_my_email
    and_i_confirm_the_sign_in
    then_i_see_the_before_you_start_page

    when_click_on_the_apply_for_teacher_training_link_in_the_header
    then_i_should_see_the_application_page
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def given_i_am_a_candidate_without_an_account
    @email = "#{SecureRandom.hex}@example.com"
  end

  def when_i_go_to_sign_up
    visit '/'

    choose 'No, I need to create an account'
    click_button t('continue')
  end

  def and_i_submit_my_email_address
    fill_in t('authentication.sign_up.email_address.label'), with: @email
    check t('authentication.sign_up.accept_terms_checkbox')
    click_on t('continue')
  end

  def then_i_receive_an_email_inviting_me_to_sign_up
    open_email(@email)
    expect(current_email.subject).to have_content t('authentication.sign_up.email.subject')
  end

  def when_the_magic_link_token_is_expired
    Timecop.safe_mode = false
    Timecop.travel (AuthenticationToken::MAX_TOKEN_DURATION + 1.minute).from_now
  ensure
    Timecop.safe_mode = true
  end

  def and_i_click_on_the_link_in_my_email
    click_magic_link_in_email
  end

  def and_i_confirm_the_sign_in
    confirm_sign_in
  end

  def then_i_am_taken_to_the_expired_link_page
    expect(page).to have_current_path(candidate_interface_expired_sign_in_path, ignore_query: true)
  end

  def when_i_click_the_button_to_send_me_a_sign_in_email
    click_button t('authentication.expired_token.button')
  end

  def then_i_receive_an_email_inviting_me_to_sign_in
    open_email(@email)
    expect(current_email.subject).to have_content t('authentication.sign_in.email.subject')
  end

  def then_i_see_the_before_you_start_page
    expect(page).to have_current_path(candidate_interface_before_you_start_path)
  end

  def when_click_on_the_apply_for_teacher_training_link_in_the_header
    click_link 'Apply for teacher training'
  end

  def then_i_should_see_the_application_page
    expect(page).to have_current_path(candidate_interface_application_form_path)
  end
end

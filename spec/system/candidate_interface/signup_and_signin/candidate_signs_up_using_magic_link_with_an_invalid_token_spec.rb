require 'rails_helper'

RSpec.describe 'Candidate tries to sign up using magic link with an invalid token' do
  include SignInHelper

  scenario 'Candidate signs in and receives an email inviting them to sign up' do
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
    and_i_confirm_the_account_creation
    then_i_see_my_application_form

    when_click_on_the_apply_for_teacher_training_link_in_the_header
    then_i_see_the_application_page
  end

  def given_i_am_a_candidate_without_an_account
    @email = "#{SecureRandom.hex}@example.com"
  end

  def when_i_go_to_sign_up
    visit '/'

    choose 'No, I need to create an account'
    click_link_or_button t('continue')
  end

  def and_i_submit_my_email_address
    fill_in t('authentication.sign_up.email_address.label'), with: @email
    click_link_or_button t('continue')
  end

  def then_i_receive_an_email_inviting_me_to_sign_up
    open_email(@email)
    expect(current_email.subject).to have_content t('authentication.sign_up.email.subject')
  end

  def when_the_magic_link_token_is_expired
    advance_time_to((AuthenticationToken::MAX_TOKEN_DURATION + 1.minute).from_now)
  end

  def and_i_click_on_the_link_in_my_email
    click_magic_link_in_email
  end

  def and_i_confirm_the_account_creation
    confirm_create_account
  end

  def then_i_am_taken_to_the_expired_link_page
    expect(page).to have_current_path(candidate_interface_expired_sign_in_path, ignore_query: true)
  end

  def when_i_click_the_button_to_send_me_a_sign_in_email
    click_link_or_button t('authentication.expired_token.button')
  end

  def then_i_receive_an_email_inviting_me_to_sign_in
    open_email(@email)
    expect(current_email.subject).to have_content t('authentication.sign_in.email.subject')
  end

  def then_i_see_my_application_form
    expect(page).to have_current_path(candidate_interface_details_path)
  end

  def when_click_on_the_apply_for_teacher_training_link_in_the_header
    click_link_or_button 'Apply for teacher training'
  end

  def then_i_see_the_application_page
    expect(page).to have_current_path(candidate_interface_details_path)
  end
end

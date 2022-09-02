require 'rails_helper'

RSpec.feature 'Candidate account' do
  include SignInHelper
  scenario 'Two candidates on the same machine sign in one after the other' do
    given_i_am_the_first_candidate
    then_i_can_sign_up_and_sign_out(@first_email)

    given_i_am_the_second_candidate
    then_i_can_sign_up_and_sign_out(@second_email)

    when_i_click_the_link_in_the_email_for(@first_email)
    then_i_am_prompted_to_get_a_new_magic_link

    when_i_click_the_link_in_the_email_for(@second_email)
    then_i_am_prompted_to_get_a_new_magic_link
  end

  def then_i_can_sign_up_and_sign_out(email)
    when_i_visit_the_signup_page
    and_i_submit_my_email_address(email)
    then_i_receive_an_email_with_a_signup_link(email)

    given_i_store_the_received_email_link_for(email)

    when_i_click_the_link_in_the_email_for(email)
    and_confirm_my_account
    then_i_am_signed_in_with(email)

    when_i_click_the_sign_out_button
    then_i_should_be_signed_out
  end

  def when_i_sign_out
    when_i_click_the_sign_out_button
    then_i_should_be_signed_out
  end

  def given_i_am_the_first_candidate
    @first_email = "first-#{SecureRandom.hex}@example.com"
  end

  def given_i_am_the_second_candidate
    @second_email = "second-#{SecureRandom.hex}@example.com"
  end

  def when_i_visit_the_signup_page
    visit candidate_interface_sign_up_path
  end

  def and_i_submit_my_email_address(email)
    fill_in t('authentication.sign_up.email_address.label'), with: email
    click_on t('continue')
  end

  def then_i_receive_an_email_with_a_signup_link(email)
    open_email(email)
    expect(current_email.subject).to have_content t('authentication.sign_up.email.subject')
  end

  def given_i_store_the_received_email_link_for(email)
    @email_link_for ||= {}
    @email_link_for[email] = current_email.find_css('a').first
  end

  def when_i_click_the_link_in_the_email_for(email)
    @email_link_for[email].click
  end

  def and_confirm_my_sign_in
    confirm_sign_in
  end

  def and_confirm_my_account
    confirm_create_account
  end

  def then_i_am_prompted_to_get_a_new_magic_link
    expect(page).to have_content 'The link you clicked has expired'
  end

  def when_i_click_the_link_in_the_email_after_an_hour_for(email)
    Timecop.travel(1.hour.from_now + 1.second) do
      @email_link_for[email].click
    end
  end

  def then_i_am_signed_in_with(email)
    within 'header' do
      expect(page).to have_content email
    end
  end

  def when_i_click_the_sign_out_button
    click_link 'Sign out'
  end

  def then_i_should_be_signed_out
    expect(page).not_to have_selector :link_or_button, 'Sign out'
    expect(page).to have_current_path(candidate_interface_create_account_or_sign_in_path)
  end
end

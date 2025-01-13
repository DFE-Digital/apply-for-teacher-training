require 'rails_helper'

RSpec.describe 'Candidate account' do
  include SignInHelper
  scenario 'Two candidates on the same machine sign in one after the other' do
    stub_const('TestUser', Struct.new(:name, :email))

    given_i_am_the_first_candidate
    then_i_can_sign_up_and_sign_out(@first_user)

    given_i_am_the_second_candidate
    then_i_can_sign_up_and_sign_out(@second_user)

    when_i_click_the_link_in_the_email_for(@first_user.email)
    then_i_am_prompted_to_get_a_new_magic_link

    when_i_click_the_link_in_the_email_for(@second_user.email)
    then_i_am_prompted_to_get_a_new_magic_link
  end

  def then_i_can_sign_up_and_sign_out(user)
    when_i_visit_the_signup_page
    and_i_submit_my_email_address(user.email)
    then_i_receive_an_email_with_a_signup_link(user.email)

    given_i_store_the_received_email_link_for(user.email)

    when_i_click_the_link_in_the_email_for(user.email)
    and_confirm_my_account
    and_enter_my_personal_information(user.name)
    then_i_am_signed_in_with(user.name)

    when_i_click_the_sign_out_button
    then_i_am_signed_out
  end

  def when_i_sign_out
    when_i_click_the_sign_out_button
    then_i_am_signed_out
  end

  def given_i_am_the_first_candidate
    @first_user = TestUser.new('first_user', "first-#{SecureRandom.hex}@example.com")
  end

  def given_i_am_the_second_candidate
    @second_user = TestUser.new('second_user', "second-#{SecureRandom.hex}@example.com")
  end

  def when_i_visit_the_signup_page
    visit candidate_interface_sign_up_path
  end

  def and_i_submit_my_email_address(email)
    fill_in t('authentication.sign_up.email_address.label'), with: email
    click_link_or_button t('continue')
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
    expect(page).to have_content 'The link you used to sign in has expired'
  end

  def when_i_click_the_link_in_the_email_after_an_hour_for(email)
    travel_temporarily_to(1.hour.from_now + 1.second) do
      @email_link_for[email].click
    end
  end

  def and_enter_my_personal_information(name)
    click_link_or_button 'Personal information'
    fill_in 'First name', with: name
    fill_in 'Last name', with: 'Smith'
    fill_in 'Day', with: '1'
    fill_in 'Month', with: '1'
    fill_in 'Year', with: '1990'

    click_link_or_button 'Save and continue'
    click_link_or_button 'GOV.UK'
  end

  def then_i_am_signed_in_with(name)
    click_link_or_button 'Personal information'

    expect(page).to have_css("input[value=#{name}]")
  end

  def when_i_click_the_sign_out_button
    click_link_or_button 'Sign out'
  end

  def then_i_am_signed_out
    expect(page).to have_no_selector :link_or_button, 'Sign out'
    expect(page).to have_current_path(candidate_interface_create_account_or_sign_in_path)
  end
end

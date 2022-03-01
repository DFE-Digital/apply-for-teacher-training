require 'rails_helper'

RSpec.feature 'Candidate account' do
  include SignInHelper

  scenario 'Candidate signs up, out, and in again' do
    given_i_am_a_candidate_without_an_account

    when_i_visit_the_signup_page
    and_i_submit_my_email_address
    then_i_should_see_validation_errors_for_the_terms_and_conditions

    when_i_visit_the_signup_page
    and_i_accept_the_ts_and_cs
    and_i_submit_without_entering_an_email
    then_i_see_form_errors_on_the_page
    and_the_ts_and_cs_are_still_checked

    when_i_visit_the_signup_page
    and_i_accept_the_ts_and_cs
    and_i_submit_my_email_address
    then_i_receive_an_email_with_a_signup_link
    when_i_click_on_the_link_in_my_email
    then_i_am_signed_in

    when_i_click_the_sign_out_button
    then_i_should_be_signed_out

    when_i_visit_the_signin_page
    and_i_submit_an_invalid_email_address
    then_i_see_form_errors_on_the_page

    when_i_visit_the_signin_page
    and_i_submit_my_email_address
    then_i_receive_an_email_with_a_signin_link
    when_i_click_on_the_link_in_my_email
    then_i_am_signed_in

    when_i_click_the_sign_out_button

    when_i_visit_the_signup_page
    and_i_submit_my_email_address
    then_i_receive_an_email_with_a_signin_link
    when_i_click_on_the_link_in_my_email
    then_i_am_signed_in

    when_i_signed_in_more_than_a_week_ago
    then_i_should_be_signed_out

    when_i_visit_the_signin_page
    and_i_submit_my_email_address_in_uppercase
    then_i_receive_an_email_with_a_signin_link

    when_i_visit_the_signup_page
    and_i_submit_my_email_address_in_uppercase
    then_i_receive_an_email_with_a_signin_link
  end

  def given_i_am_a_candidate_without_an_account
    @email = "#{SecureRandom.hex}@example.com"
  end

  def when_i_visit_the_signup_page
    visit candidate_interface_sign_up_path
  end

  def then_i_should_see_validation_errors_for_the_terms_and_conditions
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/sign_up_form.attributes.accept_ts_and_cs.blank')
  end

  def and_i_accept_the_ts_and_cs
    check t('authentication.sign_up.accept_terms_checkbox')
  end

  def and_i_submit_my_email_address(email = @email)
    fill_in t('authentication.sign_up.email_address.label'), with: email
    click_on t('continue')
  end

  def and_i_submit_without_entering_an_email
    click_on t('continue')
  end

  def and_the_ts_and_cs_are_still_checked
    expect(page).to have_checked_field t('authentication.sign_up.accept_terms_checkbox')
  end

  def and_i_submit_my_email_address_in_uppercase
    and_i_submit_my_email_address(@email.upcase)
  end

  def then_i_receive_an_email_with_a_signup_link
    open_email(@email)
    expect(current_email.subject).to have_content t('authentication.sign_up.email.subject')
  end

  def then_i_receive_an_email_with_a_signin_link
    open_email(@email)
    expect(current_email.subject).to have_content t('authentication.sign_in.email.subject')
  end

  def when_i_click_on_the_link_in_my_email
    click_magic_link_in_email
    confirm_sign_in
  end

  def then_i_am_signed_in
    within 'header' do
      expect(page).to have_content @email
    end
  end

  def when_i_click_the_sign_out_button
    click_link 'Sign out'
  end

  def then_i_should_be_signed_out
    expect(page).not_to have_selector :link_or_button, 'Sign out'
    expect(page).to have_current_path(candidate_interface_create_account_or_sign_in_path)
  end

  def when_i_visit_the_signin_page
    visit candidate_interface_sign_in_path
  end

  def when_i_signed_in_more_than_a_week_ago
    Timecop.travel(7.days.from_now + 1.second) do
      visit candidate_interface_application_form_path
    end
  end

  def and_i_submit_an_invalid_email_address
    fill_in t('authentication.sign_up.email_address.label'), with: 'invalid email'
    click_on t('continue')
  end

  def then_i_see_form_errors_on_the_page
    expect(page).to have_content 'There is a problem'
  end
end

require 'rails_helper'

RSpec.describe 'Candidate account' do
  include SignInHelper

  scenario 'Candidate signs in with and without OneLogin setup' do
    given_i_am_a_candidate_with_an_account

    when_i_visit_the_sign_in_page
    and_i_submit_an_invalid_email_address
    then_i_see_form_errors_on_the_page

    # Sign in - no OneLoginAuth
    when_i_visit_the_sign_in_page
    and_i_submit_my_email_address
    then_i_receive_an_email_with_a_sign_in_link
    when_i_click_on_the_link_in_my_email
    and_i_confirm_sign_in
    then_i_am_signed_in

    when_i_click_the_sign_out_button

    # Sign in - with OneLoginAuth, using Candidate email address
    given_i_have_a_connected_my_one_login_account
    when_i_visit_the_sign_in_page
    and_i_submit_my_email_address
    then_i_receive_an_email_with_a_sign_in_link
    when_i_click_on_the_link_in_my_email
    and_i_confirm_sign_in
    then_i_am_signed_in

    when_i_click_the_sign_out_button

    # Sign in - with OneLoginAuth, using OneLoginAuth email address
    given_i_have_a_connected_my_one_login_account
    when_i_visit_the_sign_in_page
    and_i_submit_my_one_login_email_address
    then_i_receive_an_email_at_my_one_login_email_address_with_a_sign_in_link
    when_i_click_on_the_link_in_my_email
    and_i_confirm_sign_in
    then_i_am_signed_in
  end

private

  def given_i_am_a_candidate_with_an_account
    @email = 'candidate@email.address'
    create(:candidate, email_address: @email)
  end

  def when_i_visit_the_sign_in_page
    visit candidate_interface_sign_in_path
  end

  def and_i_submit_an_invalid_email_address
    fill_in t('authentication.sign_up.email_address.label'), with: 'invalid email'
    click_link_or_button t('continue')
  end

  def then_i_see_form_errors_on_the_page
    expect(page).to have_content 'There is a problem'
  end

  def and_i_submit_my_email_address(email = @email)
    fill_in t('authentication.sign_up.email_address.label'), with: email
    click_link_or_button t('continue')
  end

  def then_i_receive_an_email_with_a_sign_in_link(email = @email)
    open_email(email)
    expect(current_email.subject).to have_content t('authentication.sign_in.email.subject')
  end

  def when_i_click_on_the_link_in_my_email
    click_magic_link_in_email
  end

  def and_i_confirm_sign_in
    confirm_sign_in
  end

  def then_i_am_signed_in
    within '.govuk-header__navigation-list' do
      expect(page).to have_content 'Sign out'
    end
  end

  def when_i_click_the_sign_out_button
    click_link_or_button 'Sign out'
  end

  def given_i_have_a_connected_my_one_login_account
    @one_login_email_address = 'one_login@email.address'
    candidate = Candidate.find_by(email_address: @email)
    create(:one_login_auth, candidate: candidate, email_address: @one_login_email_address) if candidate.one_login_auth.blank?
  end

  def and_i_submit_my_one_login_email_address
    and_i_submit_my_email_address(@one_login_email_address)
  end

  def then_i_receive_an_email_at_my_one_login_email_address_with_a_sign_in_link
    then_i_receive_an_email_with_a_sign_in_link(@one_login_email_address)
  end
end

require 'rails_helper'

RSpec.describe 'A support user authenticates via DfE Sign-in' do
  include DfESignInHelpers

  scenario 'signing in successfully' do
    given_i_have_a_dfe_sign_in_account_and_support_authorisation

    when_i_visit_a_page_in_the_support_interface
    then_i_am_redirected_to_login_page
    and_i_do_not_see_support_menu

    when_i_sign_in_via_dfe_sign_in

    then_i_am_redirected_to_the_support_interface_users_path
    and_i_have_received_an_email_about_the_new_login
    and_i_see_my_email_address
    and_my_profile_details_are_refreshed

    when_i_click_sign_out
    then_i_see_the_login_page_again

    when_i_sign_in_via_dfe_sign_in
    and_i_have_not_received_an_email_about_the_new_login

    when_i_visit_the_sign_in_page
    then_i_am_redirected_to_the_support_interface_applications_path
    and_i_see_my_email_address
  end

  def given_i_have_a_dfe_sign_in_account_and_support_authorisation
    user_exists_in_dfe_sign_in(email_address: 'user@apply-support.com', dfe_sign_in_uid: 'abc', first_name: 'John')
    user_is_a_support_user(email_address: 'user@apply-support.com', dfe_sign_in_uid: 'abc')
  end

  def when_i_visit_a_page_in_the_support_interface
    visit support_interface_candidates_path(some_key: 'some_value')
  end

  def then_i_am_redirected_to_login_page
    expect(page).to have_current_path support_interface_sign_in_path
  end

  def and_i_do_not_see_support_menu
    expect(page).to have_no_link 'Candidates'
    expect(page).to have_no_link 'Providers'
    expect(page).to have_no_link 'Performance'
    expect(page).to have_no_link 'Settings'
    expect(page).to have_no_link 'Documentation'
  end

  def when_i_sign_in_via_dfe_sign_in
    click_link_or_button 'Sign in using DfE Sign-in'
  end

  def then_i_am_redirected_to_the_support_interface_users_path
    expect(page).to have_current_path support_interface_candidates_path(some_key: 'some_value')
  end

  def and_i_have_received_an_email_about_the_new_login
    open_email('user@apply-support.com')
    expect(current_email.subject).to have_content('New sign in to Support for Apply')
    clear_emails
  end

  def and_i_see_my_email_address
    expect(page).to have_content('user@apply-support.com')
  end

  def and_my_profile_details_are_refreshed
    support_user = SupportUser.find_by email_address: 'user@apply-support.com'
    expect(support_user.first_name).to eq('John')
  end

  def when_i_click_sign_out
    click_link_or_button 'Sign out'
  end

  def then_i_see_the_login_page_again
    expect(page).to have_button('Sign in using DfE Sign-in')
  end

  def and_i_have_not_received_an_email_about_the_new_login
    open_email('user@apply-support.com')
    expect(current_email).to be_nil
  end

  def when_i_visit_the_sign_in_page
    visit support_interface_sign_in_path
  end

  def then_i_am_redirected_to_the_support_interface_applications_path
    expect(page).to have_current_path support_interface_applications_path
  end
end

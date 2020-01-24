require 'rails_helper'

RSpec.describe 'A support user authenticates via DfE Sign-in' do
  include DfESignInHelpers

  scenario 'signing in successfully' do
    given_i_have_a_dfe_sign_in_account_and_support_authorisation

    when_i_visit_the_support_interface
    then_i_should_be_redirected_to_login_page
    and_i_should_not_see_support_menu

    when_i_sign_in_via_dfe_sign_in

    then_i_should_be_redirected_to_the_support_home_page
    and_i_should_see_my_email_address
    and_my_profile_details_are_refreshed

    when_i_click_sign_out
    then_i_should_see_the_login_page_again
  end

  def given_i_have_a_dfe_sign_in_account_and_support_authorisation
    user_exists_in_dfe_sign_in(email_address: 'user@apply-support.com', dfe_sign_in_uid: 'abc', first_name: 'John')
    user_is_a_support_user(email_address: 'user@apply-support.com', dfe_sign_in_uid: 'abc')
  end

  def when_i_visit_the_support_interface
    visit support_interface_applications_path
  end

  def then_i_should_be_redirected_to_login_page
    expect(page).to have_current_path support_interface_sign_in_path
  end

  def and_i_should_not_see_support_menu
    expect(page).not_to have_link 'Applications'
    expect(page).not_to have_link 'APITokens'
    expect(page).not_to have_link 'Vendors'
  end

  def when_i_sign_in_via_dfe_sign_in
    click_button 'Sign in using DfE Sign-in'
  end

  def then_i_should_be_redirected_to_the_support_home_page
    expect(page).to have_current_path support_interface_applications_path
  end

  def and_i_should_see_my_email_address
    expect(page).to have_content('user@apply-support.com')
  end

  def and_my_profile_details_are_refreshed
    support_user = SupportUser.find_by_email_address 'user@apply-support.com'
    expect(support_user.first_name).to eq('John')
  end

  def when_i_click_sign_out
    click_link 'Sign out'
  end

  def then_i_should_see_the_login_page_again
    expect(page).to have_button('Sign in using DfE Sign-in')
  end
end

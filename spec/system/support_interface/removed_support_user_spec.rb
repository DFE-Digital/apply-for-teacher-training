require 'rails_helper'

RSpec.describe 'A removed support user attempts to authenticate via DfE Sign-in' do
  include DfESignInHelpers

  scenario 'signing in as removed user' do
    given_i_have_a_dfe_sign_in_account_and_i_am_a_removed_support_user

    when_i_visit_the_support_interface
    then_i_should_be_redirected_to_login_page
    and_i_should_not_see_support_menu

    when_i_sign_in_via_dfe_sign_in

    then_i_should_not_be_authorized
  end

  def given_i_have_a_dfe_sign_in_account_and_i_am_a_removed_support_user
    user_exists_in_dfe_sign_in(email_address: 'user@apply-support.com', dfe_sign_in_uid: 'abc', first_name: 'John')
    user_is_a_removed_support_user(email_address: 'user@apply-support.com', dfe_sign_in_uid: 'abc')
  end

  def when_i_visit_the_support_interface
    visit support_interface_applications_path
  end

  def then_i_should_be_redirected_to_login_page
    expect(page).to have_current_path support_interface_sign_in_path
  end

  def and_i_should_not_see_support_menu
    expect(page).to have_no_link 'Applications'
    expect(page).to have_no_link 'APITokens'
    expect(page).to have_no_link 'Vendors'
  end

  def when_i_sign_in_via_dfe_sign_in
    click_button 'Sign in using DfE Sign-in'
  end

  def then_i_should_not_be_authorized
    expect(page).to have_current_path(auth_dfe_callback_path)
    expect(page).to have_text 'Your account is not authorized'
  end
end

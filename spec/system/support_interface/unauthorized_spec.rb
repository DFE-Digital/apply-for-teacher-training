require 'rails_helper'

RSpec.describe 'A support user authenticates via DfE Sign-in but is not authorized to access the support interface' do
  include DfESignInHelpers

  scenario 'signing in unsuccessfully (without authorization)' do
    given_i_have_a_dfe_sign_in_account

    when_i_visit_the_support_interface
    then_i_should_be_redirected_to_login_page

    when_i_sign_in_via_dfe_sign_in

    then_i_should_be_see_the_not_authorized_page
    and_i_should_see_my_dfe_sign_in_uid
    and_i_should_not_see_support_menu
  end

  def given_i_have_a_dfe_sign_in_account
    user_exists_in_dfe_sign_in(email_address: 'user@apply-support.com', dfe_sign_in_uid: 'abc')
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

  def then_i_should_be_see_the_not_authorized_page
    expect(page).to have_content 'Your account is not authorized'
  end

  def and_i_should_see_my_dfe_sign_in_uid
    expect(page).to have_content('abc')
  end
end

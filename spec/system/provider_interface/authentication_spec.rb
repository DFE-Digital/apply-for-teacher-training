require 'rails_helper'

RSpec.describe 'A provider authenticates via DfE Sign-in' do
  include DfESignInHelpers

  context 'when database authorisation for provider users is enabled' do
    before { FeatureFlag.activate('provider_permissions_in_database') }

    scenario 'signing in successfully' do
      given_i_am_registered_as_a_provider_user
      and_i_have_a_dfe_sign_in_account

      when_i_visit_the_provider_interface
      and_i_sign_in_via_dfe_sign_in

      then_i_should_see_my_email_address
    end
  end

  context 'when database authorisation for provider users is disabled' do
    scenario 'signing in successfully' do
      given_i_have_a_dfe_sign_in_account

      when_i_visit_the_provider_interface
      and_i_sign_in_via_dfe_sign_in

      then_i_should_be_redirected_to_the_provider_dashboard
      and_i_should_see_my_email_address

      when_i_click_sign_out
      then_i_should_see_the_login_page_again
    end
  end

  def given_i_am_registered_as_a_provider_user
    create(:provider_user, email_address: 'provider@example.com', dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
  end

  def and_i_have_a_dfe_sign_in_account
    provider_exists_in_dfe_sign_in(email_address: 'provider@example.com', dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
  end

  alias :given_i_have_a_dfe_sign_in_account :and_i_have_a_dfe_sign_in_account

  def when_i_visit_the_provider_interface
    visit provider_interface_path
  end

  def and_i_sign_in_via_dfe_sign_in
    click_button 'Sign in using DfE Sign-in'
  end

  def then_i_should_be_redirected_to_the_provider_dashboard; end

  def and_i_should_see_my_email_address
    expect(page).to have_content('provider@example.com')
  end

  alias :then_i_should_see_my_email_address :and_i_should_see_my_email_address

  def when_i_click_sign_out
    click_link 'Sign out'
  end

  def then_i_should_see_the_login_page_again
    expect(page).to have_button('Sign in using DfE Sign-in')
  end
end

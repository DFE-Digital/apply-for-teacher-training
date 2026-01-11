require 'rails_helper'

RSpec.describe 'A support user signs out of DSI as well as Apply' do
  include DfESignInHelpers

  let(:support_user) { create(:support_user, email_address: 'support@example.com', dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }

  scenario 'signing out destroys local session then redirects to DSI' do
    given_i_am_registered_as_a_support_user
    and_i_have_a_dfe_sign_in_account
    and_i_visit_the_support_interface_sign_in_path
    and_i_sign_in_via_dfe_sign_in

    when_i_click_on_sign_out
    then_i_am_redirected_to_dsi_end_session_endpoint
    and_dsi_redirects_me_back_to_the_support_interface
    and_i_am_already_signed_out_of_the_support_interface
  end

  def given_i_am_registered_as_a_support_user
    support_user
  end

  def and_i_have_a_dfe_sign_in_account
    support_user_exists_dsi(
      email_address: 'provider@example.com',
      dfe_sign_in_uid: 'DFE_SIGN_IN_UID',
      id_token: 'token',
    )
  end

  def and_i_visit_the_support_interface_sign_in_path
    visit support_interface_sign_in_path
  end

  def and_i_sign_in_via_dfe_sign_in
    click_link_or_button 'Sign in using DfE Sign-in'
  end

  def when_i_click_on_sign_out
    ClimateControl.modify DFE_SIGN_IN_ISSUER: 'https://identityprovider.gov.uk' do
      click_link_or_button 'Sign out'
    end
  end

  def then_i_am_redirected_to_dsi_end_session_endpoint
    expected_query = {
      id_token_hint: 'token',
      post_logout_redirect_uri: 'http://www.example.com/auth/dfe-support/sign-out',
    }

    expected_url = "https://identityprovider.gov.uk/session/end?#{expected_query.to_query}"
    expect(page.current_url).to eq(expected_url)
  end

  def and_dsi_redirects_me_back_to_the_support_interface
    # we'll just have to simulate the redirect here
    return_from_dsi_logout_path = '/auth/dfe-support/sign-out'
    visit return_from_dsi_logout_path

    expect(page).to have_current_path(support_interface_sign_in_path)
  end

  def and_i_am_already_signed_out_of_the_support_interface
    visit support_interface_candidates_path

    expect(page).to have_current_path(support_interface_sign_in_path)
  end
end

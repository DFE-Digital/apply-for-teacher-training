require 'rails_helper'

RSpec.describe 'A provider user signs out of DSI as well as Apply' do
  include DfESignInHelpers

  let(:provider_user) { create(:provider_user, email_address: 'provider@example.com', dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }

  scenario 'signing out destroys local session then redirects to DSI' do
    given_i_am_registered_as_a_provider_user
    and_i_have_a_dfe_sign_in_account
    and_i_visit_the_provider_interface_sign_in_path
    and_i_sign_in_via_dfe_sign_in

    when_i_click_on_sign_out
    then_i_am_redirected_to_dsi_end_session_endpoint
    and_dsi_redirects_me_back_to_the_provider_interface
    and_i_am_already_signed_out_of_the_provider_interface
  end

  def given_i_am_registered_as_a_provider_user
    provider_user
  end

  def and_i_have_a_dfe_sign_in_account
    provider_exists_in_dfe_sign_in(
      email_address: 'provider@example.com',
      dfe_sign_in_uid: 'DFE_SIGN_IN_UID',
    )
  end

  def and_i_visit_the_provider_interface_sign_in_path
    visit provider_interface_sign_in_path
  end

  def and_i_sign_in_via_dfe_sign_in
    click_link_or_button 'Sign in using DfE Sign-in'
  end

  def when_i_click_on_sign_out
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(DfESignInUser).to receive(:needs_dsi_signout?).and_return(true)
    # rubocop:enable RSpec/AnyInstance
    ClimateControl.modify DFE_SIGN_IN_ISSUER: 'https://identityprovider.gov.uk' do
      click_link_or_button 'Sign out'
    end
  end

  def then_i_am_redirected_to_dsi_end_session_endpoint
    expected_query = {
      id_token_hint: nil,
      post_logout_redirect_uri: "#{HostingEnvironment.application_url}/auth/dfe/sign-out",
      state: :provider,
    }

    expected_url = "https://identityprovider.gov.uk/session/end?#{expected_query.to_query}"
    expect(page.current_url).to eq(expected_url)
  end

  def and_dsi_redirects_me_back_to_the_provider_interface
    # we'll just have to simulate the redirect here
    return_from_dsi_logout_path = '/auth/dfe/sign-out?state=provider'
    visit return_from_dsi_logout_path

    expect(page).to have_current_path(provider_interface_path)
  end

  def and_i_am_already_signed_out_of_the_provider_interface
    visit provider_interface_applications_path

    expect(page).to have_current_path(provider_interface_sign_in_path)
  end
end

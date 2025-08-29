module OneLoginHelper
  def user_exists_in_one_login(email_address: 'test@email.com', uid: 'UID')
    OmniAuth.config.mock_auth[:'one-login'] = OmniAuth::AuthHash.new(
      {
        provider: :govuk_one_login,
        uid:,
        info: {
          email: email_address,
        },
        credentials: {
          id_token: 'id_token',
        },
      },
    )
  end

  def sign_in_with_one_login(email_address)
    if FeatureFlag.active?(:one_login_candidate_sign_in)
      user_exists_in_one_login(email_address:)
      visit candidate_interface_create_account_or_sign_in_path
      click_link_or_button 'Continue'
    else
      raise 'One login feature flag needs to be active'
    end
  end

  def given_i_am_signed_in_with_one_login
    if FeatureFlag.inactive?(:one_login_candidate_sign_in)
      FeatureFlag.activate(:one_login_candidate_sign_in)
    end

    @current_candidate ||= create(:candidate)
    user_exists_in_one_login(email_address: @current_candidate.email_address)
    visit candidate_interface_create_account_or_sign_in_path
    click_link_or_button 'Continue'
  end
  alias i_am_signed_in_with_one_login :given_i_am_signed_in_with_one_login
end

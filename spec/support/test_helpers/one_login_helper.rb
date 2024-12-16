module OneLoginHelper
  def user_exists_in_onelogin(email_address: 'test@email.com', uid: 'UID')
    OmniAuth.config.mock_auth[:onelogin] = OmniAuth::AuthHash.new(
      {
        provider: 'onelogin',
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
end

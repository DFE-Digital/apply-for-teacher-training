module OneLoginHelper
  def user_exists_in_one_login(email_address: 'test@email.com', uid: 'UID')
    OmniAuth.config.mock_auth[:one_login] = OmniAuth::AuthHash.new(
      {
        provider: 'one_login',
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

module OneloginSetup
  def self.configure(builder)
    client_id = ENV.fetch('GOVUK_ONE_LOGIN_CLIENT_ID', '')
    onelogin_issuer_uri = URI(ENV.fetch('GOVUK_ONE_LOGIN_ISSUER_URL', ''))
    private_key_pem = ENV.fetch('GOVUK_ONE_LOGIN_PRIVATE_KEY', '')

    private_key_pem = private_key_pem.gsub('\n', "\n")
    host_env = HostingEnvironment.application_url
    private_key = OpenSSL::PKey::RSA.new(private_key_pem)
  rescue OpenSSL::PKey::RSAError => e
    raise e unless HostingEnvironment.development?

    builder.provider :govuk_one_login_openid_connect,
                     name: :onelogin,
                     allow_authorize_params: %i[session_id],
                     callback_path: '/auth/onelogin/callback',
                     discovery: true,
                     issuer: onelogin_issuer_uri.to_s,
                     path_prefix: '/auth',
                     post_logout_redirect_uri: "#{host_env}/auth/onelogin/sign-out-complete",
                     response_type: :code,
                     scope: %w[email openid],
                     client_auth_method: :jwt_bearer,
                     client_options: {
                       authorization_endpoint: '/oauth2/authorize',
                       end_session_endpoint: '/oauth2/logout',
                       token_endpoint: '/oauth2/token',
                       userinfo_endpoint: '/oauth2/userinfo',
                       host: onelogin_issuer_uri.host,
                       identifier: client_id,
                       port: 443,
                       redirect_uri: "#{host_env}/auth/onelogin/callback",
                       scheme: 'https',
                       private_key: private_key,
                     }
  end
end

module OneloginSetup
  def self.configure(builder)
    public_key = ENV.fetch('GOVUK_LOGIN_PUBLIC_KEY', 'something')
    onelogin_issuer_uri = URI(ENV.fetch('GOVUK_LOGIN_ISSUER_URL', 'https://website.gov.uk/'))
    private_key_pem = ENV.fetch('GOVUK_LOGIN_PRIVATE_KEY', 'something')

    private_key_pem = private_key_pem.gsub('\n', "\n")
    host_env = HostingEnvironment.application_url

    begin
      private_key = OpenSSL::PKey::RSA.new(private_key_pem)
      Rails.logger.debug 'RSA private key successfully created.'
    rescue OpenSSL::PKey::RSAError => e
      Rails.logger.debug { "Failed to create RSA private key: #{e.message}" }
    end

    builder.provider :govuk_one_login_openid_connect,
                     name: :onelogin,
                     allow_authorize_params: %i[session_id trn_token],
                     callback_path: '/auth/onelogin/callback',
                     client_auth_method: :jwt_bearer,
                     client_options: {
                       authorization_endpoint: '/oauth2/authorize',
                       end_session_endpoint: '/oauth2/logout',
                       token_endpoint: '/oauth2/token',
                       userinfo_endpoint: '/oauth2/userinfo',
                       host: onelogin_issuer_uri.host,
                       identifier: public_key,
                       port: 443,
                       redirect_uri: "#{host_env}/auth/onelogin/callback",
                       scheme: 'https',
                       private_key: private_key,
                     },
                     discovery: true,
                     issuer: onelogin_issuer_uri.to_s,
                     path_prefix: '/auth',
                     post_logout_redirect_uri: "#{host_env}/auth/onelogin/sign-out-complete",
                     back_channel_logout_uri: "#{host_env}/auth/onelogin/sign-out",
                     response_type: :code,
                     scope: %w[email openid]
  end
end

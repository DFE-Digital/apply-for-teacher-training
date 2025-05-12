module OneLoginSetup
  class OmniAuth::Strategies::GovukOneLogin < OmniAuth::Strategies::OpenIDConnect; end

  def self.configure(builder)
    client_id = ENV.fetch('GOVUK_ONE_LOGIN_CLIENT_ID', '')
    one_login_issuer_uri = URI(ENV.fetch('GOVUK_ONE_LOGIN_ISSUER_URL', ''))
    private_key_pem = ENV.fetch('GOVUK_ONE_LOGIN_PRIVATE_KEY', '')
    application_url = HostingEnvironment.application_url

    begin
      private_key_pem = private_key_pem.gsub('\n', "\n")
      private_key = OpenSSL::PKey::RSA.new(private_key_pem)
    rescue OpenSSL::PKey::RSAError => e
      Rails.logger.warn "GOVUK ONE LOGIN PRIVATE error, is the key present? #{e.message}"
    end

    builder.provider :govuk_one_login,
                     name: :one_login,
                     allow_authorize_params: %i[session_id],
                     callback_path: '/auth/one-login/callback',
                     discovery: true,
                     issuer: one_login_issuer_uri.to_s,
                     path_prefix: '/auth',
                     post_logout_redirect_uri: "#{application_url}/auth/one-login/sign-out-complete",
                     response_type: :code,
                     scope: %w[email openid],
                     client_auth_method: :jwt_bearer,
                     client_options: {
                       authorization_endpoint: '/oauth2/authorize',
                       end_session_endpoint: '/oauth2/logout',
                       token_endpoint: '/oauth2/token',
                       userinfo_endpoint: '/oauth2/userinfo',
                       host: one_login_issuer_uri.host,
                       identifier: client_id,
                       port: 443,
                       redirect_uri: "#{application_url}/auth/one-login/callback",
                       scheme: 'https',
                       private_key: private_key,
                     }
  end
end

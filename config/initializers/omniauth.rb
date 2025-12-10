OmniAuth.config.logger = Rails.logger
require 'omniauth/strategies/one_login_developer'

dfe_sign_in_identifier = ENV['DFE_SIGN_IN_CLIENT_ID']
dfe_sign_in_secret = ENV['DFE_SIGN_IN_SECRET']
dfe_sign_in_redirect_uri = URI.join(HostingEnvironment.application_url, '/auth/dfe/callback')
dfe_sign_in_issuer_uri = ENV['DFE_SIGN_IN_ISSUER'].present? ? URI(ENV['DFE_SIGN_IN_ISSUER']) : nil

options = {
  name: :dfe,
  discovery: true,
  response_type: :code,
  scope: %i[email profile],
  path_prefix: '/auth',
  callback_path: '/auth/dfe/callback',
  client_options: {
    port: dfe_sign_in_issuer_uri&.port,
    scheme: dfe_sign_in_issuer_uri&.scheme,
    host: dfe_sign_in_issuer_uri&.host,
    identifier: dfe_sign_in_identifier,
    secret: dfe_sign_in_secret,
    redirect_uri: dfe_sign_in_redirect_uri&.to_s,
  },
  issuer:
  ("#{dfe_sign_in_issuer_uri}:#{dfe_sign_in_issuer_uri.port}" if dfe_sign_in_issuer_uri.present?),
}

# this needs to be declared inline or zeitwerk complains about autoloading during initialization
# it cannot just be a local function as other parts of the codebase depend on it
module ::DfESignIn
  def self.bypass?
    (HostingEnvironment.review? || Rails.env.development?) && ENV['BYPASS_DFE_SIGN_IN'] == 'true'
  end
end

module ::OneLogin
  def self.bypass?
    HostingEnvironment.review? || Rails.env.development?
  end
end

if DfESignIn.bypass?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :developer,
             fields: %i[uid email first_name last_name],
             uid_field: :uid
  end
else
  Rails.application.config.middleware.use OmniAuth::Strategies::OpenIDConnect, options
end

if OneLogin.bypass?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :one_login_developer,
             request_path: '/auth/one-login-developer',
             callback_path: '/auth/one-login-developer/callback',
             fields: %i[uid],
             uid_field: :uid
  end
else
  private_key_pem = ENV.fetch('GOVUK_ONE_LOGIN_PRIVATE_KEY', '')
  begin
    private_key_pem = private_key_pem.gsub('\n', "\n")
    private_key = OpenSSL::PKey::RSA.new(private_key_pem)
  rescue OpenSSL::PKey::RSAError => e
    Rails.logger.warn "GOVUK ONE LOGIN PRIVATE error, is the key present? #{e.message}"
    Sentry.capture_exception(e)
  end

  application_url = HostingEnvironment.application_url

  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :govuk_one_login, {
      name: :'one-login',
      client_id: ENV.fetch('GOVUK_ONE_LOGIN_CLIENT_ID', ''),
      idp_base_url: ENV.fetch('GOVUK_ONE_LOGIN_ISSUER_URL', ''),
      scope: 'openid email',
      private_key:,
      redirect_uri: "#{application_url}/auth/one-login/callback",
      signing_algorithm: 'RS256',
    }
  end
end

require "omniauth/strategies/dfe_openid_connect"

OmniAuth.config.add_camelization('dfe_openid_connect', 'DfEOpenIDConnect')
OmniAuth.config.logger = Rails.logger

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

onelogin_issuer_uri = URI("https://oidc.integration.account.gov.uk/")

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :dfe_openid_connect,
           name: :onelogin,
           allow_authorize_params: %i[session_id trn_token],
           callback_path: "/auth/onelogin",
           send_scope_to_token_endpoint: false,
           client_options: {
             authorization_endpoint: "/oauth2/authorize",
             end_session_endpoint: "/oauth2/logout",
             token_endpoint: "/oauth2/token",
             userinfo_endpoint: "/oauth2/userinfo",
             #host: URI(ENV.fetch("ONELOGIN_API_DOMAIN", "not_set")).host,
             host: onelogin_issuer_uri.host,
             identifier: "esc5Ek1Jd1P_JX7U_eYcU6XgKBI",
             #jwks_uri: ENV["ONELOGIN_JWKS_URI"],
             port: 443,
             redirect_uri: "http://localhost:3000/auth/onelogin/callback",
             scheme: "https",
             #secret: ENV["ONELOGIN_CLIENT_SECRET"]
           },
           discovery: true,
           issuer: "https://oidc.integration.account.gov.uk/",
           path_prefix: "/auth",
           pkce: true,
           post_logout_redirect_uri: "http://localhost:3000/qualifications/sign-out",
           response_type: :code,
           scope: %w[openid email]
end

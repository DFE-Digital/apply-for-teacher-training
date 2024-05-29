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
  provider :openid_connect, {
    name: :onelogin,
    discovery: true,
    scope: %i[openid email],
    allow_authorize_params: %i[session_id trn_token],
    send_scope_to_token_endpoint: false,
    pkce: true,
    path_prefix: "/authorize",
    callback_path: "/auth/onelogin/callback",
    authorization_endpoint: "https://oidc.integration.account.gov.uk/authorize",
    token_endpoint: "https://oidc.integration.account.gov.uk/token",
    registration_endpoint: "https://oidc.integration.account.gov.uk/connect/register",
    issuer: "https://oidc.integration.account.gov.uk/",
    jwks_uri: "https://oidc.integration.account.gov.uk/.well-known/jwks.json",
    #state: Proc.new { SecureRandom.hex(32) },
    require_state: false,
    client_options: {
      port: onelogin_issuer_uri&.port,
      scheme: onelogin_issuer_uri&.scheme,
      host: onelogin_issuer_uri&.host,
      identifier: "esc5Ek1Jd1P_JX7U_eYcU6XgKBI",
      redirect_uri: "http://localhost:3000/candidate/account",
      secret: "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqEzXYcrW44Xr4/5/otrKE8fILryC9c3wyhRUuw7ELGRZUBLLFr0K9EKYxK4q1qq8KmcEggbnN6lR63rctimfzRPsqORkRoVaGeLOIKobhlFv57mljbCovd8q+m1z3oHP5aQOqkHsqln/TMX6v6dkz9U0ChS/Wd3TG2JKmMP7FBtucYw4RaR5fzoQVSW8jrtsDGasuhtQgXNNlhJj5QPY3XLtOhG4RnHeYUAQo1IUc17n5LEXaigafhMYbl1+Je4XeKGZLO42sRpWalexa5m7bcRzoeLDSmfydxeNxeEh8/VFBtZySlHhIQUuUPv2G89ZfHjFAvLjXxzPyklnmYswRQIDAQAB"
    },
  }
end

#Rails.application.config.middleware.use OmniAuth::Builder do
#  provider :openid_connect, {
#    name: :my_provider,
#    scope: [:openid, :email, :profile, :address],
#    response_type: :code,
#    uid_field: "preferred_username",
#    client_options: {
#      port: 443,
#      scheme: "https",
#      host: "myprovider.com",
#      identifier: ENV["OP_CLIENT_ID"],
#      secret: ENV["OP_SECRET_KEY"],
#      redirect_uri: "http://myapp.com/users/auth/openid_connect/callback",
#    },
#  }
#end

# # this needs to be declared inline or zeitwerk complains about autoloading during initialization
# # it cannot just be a local function as other parts of the codebase depend on it
# module ::DfESignIn
#   def self.bypass?
#     (HostingEnvironment.review? || HostingEnvironment.loadtest? || Rails.env.development?) && ENV['BYPASS_DFE_SIGN_IN'] == 'true'
#   end
# end

# if DfESignIn.bypass?
#   Rails.application.config.middleware.use OmniAuth::Builder do
#     provider :developer,
#              fields: %i[uid email first_name last_name],
#              uid_field: :uid
#   end
# else
#   Rails.application.config.middleware.use OmniAuth::Strategies::OpenIDConnect, options
# end

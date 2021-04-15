require_relative '../../app/middlewares/apply/content_security_policy_middleware'

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.config.content_security_policy do |policy|
  # Include sources for Google Analytics and ZenDesk integration
  policy.default_src :self, :https, 'www.googletagmanager.com', 'static.zdassets.com'
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data
  policy.object_src  :none
  policy.script_src  :self, :https, 'www.googletagmanager.com', 'static.zdassets.com', :unsafe_inline, :unsafe_eval
  policy.style_src   :self, :https, :unsafe_inline

  # For ZenDesk chat
  policy.connect_src :self, :https, 'wss://widget-mediator.zopim.com'

  # Specify URI for violation reports
  # policy.report_uri "/csp-violation-report-endpoint"
end

# If you are using UJS then enable automatic nonce generation
Rails.application.config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }

# Set the nonce only to specific directives
Rails.application.config.content_security_policy_nonce_directives = %w[script-src]

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true

# Subclass the built-in CSP middleware so that we can feature flag it.
# Delete this when retiring the :content_security_policy feature flag.
Rails.application.configure do
  config.middleware.insert_after ActionDispatch::ContentSecurityPolicy::Middleware, Apply::ContentSecurityPolicyMiddleware
  config.middleware.delete ActionDispatch::ContentSecurityPolicy::Middleware
end

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    # Include sources for Google Analytics and ZenDesk integration
    policy.default_src :self, :https, "www.googletagmanager.com", "static.zdassets.com", "clarity.ms"
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    policy.script_src  :self, :https, "www.googletagmanager.com", "static.zdassets.com", "clarity.ms", :unsafe_eval
    policy.style_src   :self, :https, :unsafe_inline
    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"

    # For ZenDesk chat
    policy.connect_src :self, :https, "wss://widget-mediator.zopim.com"
  end

  # Generate session nonces for permitted importmap, inline scripts, and inline styles.
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]

  # Report violations without enforcing the policy.
  # config.content_security_policy_report_only = true
end

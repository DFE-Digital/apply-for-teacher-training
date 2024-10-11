class SandboxInterceptor
  PROVIDER_EMAIL_ALLOW_LIST = %w[fallback_sign_in_email permissions_granted].freeze

  def self.delivering_email(message)
    return unless HostingEnvironment.sandbox_mode?

    if message.rails_mailer == 'provider_mailer' && PROVIDER_EMAIL_ALLOW_LIST.exclude?(message.rails_mail_template)
      message.perform_deliveries = false
    end
  end
end

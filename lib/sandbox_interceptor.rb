class SandboxInterceptor
  PROVIDER_EMAIL_ALLOWLIST = %w[fallback_sign_in_email permissions_granted].freeze

  def self.delivering_email(message)
    return unless HostingEnvironment.sandbox_mode?

    if message.header['rails_mailer'].value == 'provider_mailer' &&
       PROVIDER_EMAIL_ALLOWLIST.exclude?(message.header['rails_mail_template'].value)
      message.perform_deliveries = false
    end
  end
end

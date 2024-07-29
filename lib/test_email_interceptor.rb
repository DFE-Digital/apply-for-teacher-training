class TestEmailInterceptor
  def self.delivering_email(message)
    if message.to.any? { |email| email.end_with?('@example.com') }
      Rails.logger.info("Skipping email to #{message.to} ('#{message.subject}')") unless HostingEnvironment.production?
      message.perform_deliveries = false
    end
  end
end

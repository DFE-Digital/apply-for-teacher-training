class EnvironmentFlagInterceptor
  def self.delivering_email(message)
    unless HostingEnvironment.production?
      message.subject = "[#{HostingEnvironment.environment_name.upcase}] #{message.subject}"
    end
  end
end

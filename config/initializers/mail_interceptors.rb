require 'test_email_interceptor'
require 'environment_flag_interceptor'
require 'email_log_interceptor'
require 'sandbox_interceptor'

if Rails.env.production?
  ActionMailer::Base.register_interceptor(TestEmailInterceptor)
end

ActionMailer::Base.register_interceptor(SandboxInterceptor)
ActionMailer::Base.register_interceptor(EnvironmentFlagInterceptor)
ActionMailer::Base.register_interceptor(EmailLogInterceptor)

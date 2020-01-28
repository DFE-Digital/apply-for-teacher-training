require 'test_email_interceptor'
require 'environment_flag_interceptor'

if Rails.env.production?
  ActionMailer::Base.register_interceptor(TestEmailInterceptor)
end

ActionMailer::Base.register_interceptor(EnvironmentFlagInterceptor)

require 'test_email_interceptor'

if Rails.env.production?
  ActionMailer::Base.register_interceptor(TestEmailInterceptor)
end

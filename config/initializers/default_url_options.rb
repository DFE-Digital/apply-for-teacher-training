uri = URI(HostingEnvironment.application_url)
application_config = Rails.application.routes
mailer_config = ActionMailer::Base

[application_config, mailer_config].each do |config|
  config.default_url_options[:host] = uri.host
  config.default_url_options[:port] = uri.port
  config.default_url_options[:protocol] = uri.scheme
end

Raven.configure do |config|
  config.current_environment = HostingEnvironment.environment_name
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.excluded_exceptions += [
    'ActionController::UnknownHttpMethod',
    'ActionDispatch::Http::Parameters::ParseError',
  ]
end

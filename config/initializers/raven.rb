Raven.configure do |config|
  config.silence_ready = true
  config.current_environment = HostingEnvironment.environment_name
  config.release = ENV['SHA']
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.inspect_exception_causes_for_exclusion = true

  config.excluded_exceptions += [
    # The following exceptions are user-errors that aren't actionable, and can be
    # safely ignored.
    'ActionController::BadRequest',
    'ActionController::UnknownFormat',
    'ActionController::UnknownHttpMethod',
    'ActionDispatch::Http::Parameters::ParseError',
    'Mime::Type::InvalidMimeType',

    # Errors in the TTAPI sync are often transient errors with the API. We
    # have monitoring in place to make sure the sync succeeds every couple of
    # hours, so we don't need to be notified of individual failures.
    'TeacherTrainingPublicAPI::SyncError',

    # These Postgres errors often occur when Azure has maintenance and drops
    # connections. Most of the time they aren't actionable. We are able to filter
    # them because our smoke tests and healthchecks will alert on persistent
    # database issues.
    'PG::ConnectionBad',
    'PG::UnableToSend',

    # Similarly, errors in Redis don't provide us with actionable information
    # in Sentry.
    'Redis::TimeoutError',
    'Redis::CannotConnectError',
  ]
end

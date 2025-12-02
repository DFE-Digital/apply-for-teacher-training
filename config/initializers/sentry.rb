Sentry.init do |config|
  config.environment = HostingEnvironment.environment_name
  config.release = ENV['SHA']
  filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)

  config.before_send = lambda do |event, hint|
    if hint[:exception].is_a?(ActiveRecord::RecordNotUnique)
      # rubocop:disable Style/HashEachMethods
      event.exception.values.each do |single_exception|
        single_exception.value.gsub!(/^DETAIL:.*$/, '[PG DETAIL FILTERED]')
      end
      # rubocop:enable Style/HashEachMethods
    end

    event.extra = filter.filter(event.extra) if event.extra
    event.user = filter.filter(event.user) if event.user
    event.contexts = filter.filter(event.contexts) if event.contexts
    event
  end

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

    # Google cloud (ie Bigquery) errors are usually caused by transient network
    # issues. If there's a genuine problem the queues will stack up and the Sidekiq
    # latency check will alert. That takes at most 100 seconds to happen, so if
    # something is actually wrong it's not meaningfully less useful than hearing about
    # it via Sentry.
    'Google::Cloud::Error',
  ]
end

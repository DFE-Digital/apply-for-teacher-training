require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

    config.x.read_only_database_url = if HostingEnvironment.review?
                                      # On Heroku we don't have a read replica, so use the main database connection.
                                      ENV.fetch("DATABASE_URL")
                                    else
                                      ENV.fetch("BLAZER_DATABASE_URL")
                                    end

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Disable serving static files from `public/`, relying on NGINX/Apache to do so instead.
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=3600" }

  # Do not fall back to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  config.asset_host = ENV["RAILS_ASSETS_HOST"]

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  # config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  config.ssl_options = {
    # `force_ssl` by default does a redirect of non-https domains to https.
    # That does not work in our case, because SSL is terminated at the Azure layer.
    redirect: false,

    # Cookies will not be sent over http
    secure_cookies: true,

    # HSTS: tell the browser to never load HTTP version of the site
    hsts: true,
  }

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger = ActiveSupport::Logger.new(STDOUT)
                                       .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
                                       .then { |logger| ActiveSupport::TaggedLogging.new(logger) }
  config.log_format = :json                               # For parsing in Logit
  config.rails_semantic_logger.add_file_appender = false  # Don't log to file
  config.active_record.logger = nil                       # Don't log SQL
  config.rails_semantic_logger.format = :json
  config.semantic_logger.add_appender(
    io: $stdout,
    level: config.log_level,
    formatter: config.rails_semantic_logger.format,
    )

  # Change to "debug" to log everything (including potentially personally-identifiable information!)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  config.cache_store = :redis_cache_store, { url: ENV.fetch("REDIS_CACHE_URL") }

  # Replace the default in-process and non-durable queuing backend for Active Job.
  # config.active_job.queue_adapter = :resque
  # config.active_job.queue_name_prefix = "apply_for_postgraduate_teacher_training_production"

  # Disable caching for Action Mailer templates even if Action Controller
  # caching is enabled.
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :notify
  config.action_mailer.notify_settings = {
    api_key: ENV.fetch("GOVUK_NOTIFY_API_KEY"),
  }

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  #
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }


  # Controls whether the PostgresqlAdapter should decode dates automatically with manual queries.
  #
  # Example:
  #   ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.select_value("select '2024-01-01'::date") #=> Date
  #
  # This query will return a `String` if postgresql_adapter_decode_dates is set to false.
  config.active_record.postgresql_adapter_decode_dates = false

  class FixAzureXForwardedForMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      # ActionDispatch::RemoteIp::GetIp does not support IP addresses with
      # ports included in the CLIENT_IP or X_FORWARDED_FOR headers. Azure includes
      # ports with these IPs, so they're ignored when remote_ip is calculated.
      #
      # In practice this means remote_ip always returns REMOTE_ADDR on Azure,
      # even though it falls within 172.16.0.0/12 and is therefore known to be
      # a private IP.
      #
      # Rack has solved this issue long ago: https://github.com/rack/rack/issues/1227
      # so use Rack's own parsing to overwrite this header before it
      # gets to ActionDispatch::RemoteIp
      req = Rack::Request.new(env)

      if req.forwarded_for.present?
        env["HTTP_X_FORWARDED_FOR"] = req.forwarded_for.join(",")
      end

      # preserves access to sidekiq web
      # see https://github.com/sinatra/sinatra/blob/master/rack-protection/lib/rack/protection/ip_spoofing.rb#L17
      if env["HTTP_X_CLIENT_IP"].present?
        env["HTTP_CLIENT_IP"] = env["HTTP_X_CLIENT_IP"]
      end

      @app.call(env)
    end
  end

  config.middleware.insert_before ActionDispatch::RemoteIp, FixAzureXForwardedForMiddleware

  # Don't add AWS IP ranges on AKS.
  config.action_dispatch.trusted_proxies = if ENV["KUBERNETES_SERVICE_HOST"].present?
                                             [
                                               ActionDispatch::RemoteIp::TRUSTED_PROXIES,
                                             ]
                                           else
                                             # Add AWS IP addresses to trusted proxy list
                                             [
                                               ActionDispatch::RemoteIp::TRUSTED_PROXIES,
                                               Modules::AWSIpRanges.cloudfront_ips.map { |proxy| IPAddr.new(proxy) },
                                             ].flatten
                                           end

  config.active_storage.service = :azure
end

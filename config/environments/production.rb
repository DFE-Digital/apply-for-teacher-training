require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  if HostingEnvironment.review?
    # On Heroku we don't have a read replica, so use the main database connection.
    config.x.read_only_database_url = ENV.fetch('DATABASE_URL')
  else
    config.x.read_only_database_url = ENV.fetch('BLAZER_DATABASE_URL')
  end

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  config.cache_store = :redis_cache_store, { url: ENV.fetch('REDIS_CACHE_URL') }

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  if ENV.key?('RAILS_ASSETS_HOST')
    # Enable serving of images, stylesheets, and JavaScripts from an asset server.
    config.action_controller.asset_host = ENV['RAILS_ASSETS_HOST']
  end

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # https://edgeapi.rubyonrails.org/classes/ActionDispatch/SSL.html
  config.force_ssl = true
  config.ssl_options = {
    # `force_ssl` by default does a redirect of non-https domains to https. That does not work
    # in our case, because SSL is terminated at the Azure layer.
    redirect: false,

    # Cookies will not be sent over http
    secure_cookies: true,

    # HSTS: tell the browser to never load HTTP version of the site
    hsts: true,
  }

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "apply_for_postgraduate_teacher_training_production"

  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :notify
  config.action_mailer.notify_settings = {
    api_key: ENV.fetch('GOVUK_NOTIFY_API_KEY')
  }

  # for default_url_options, see config/initializers/default_url_options.rb

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Logging configuration
  config.log_level = :info

  # log to STDOUT using standard verbose format + request_id + timestamp
  config.log_tags = [ :request_id ] # prepend these to log lines

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  config.active_record.logger = nil # Don't log SQL in production

  config.rails_semantic_logger.add_file_appender = false

  # Inserts middleware to perform automatic connection switching.
  # The `database_selector` hash is used to pass options to the DatabaseSelector
  # middleware. The `delay` is used to determine how long to wait after a write
  # to send a subsequent read to the primary.
  #
  # The `database_resolver` class is used by the middleware to determine which
  # database is appropriate to use based on the time delay.
  #
  # The `database_resolver_context` class is used by the middleware to set
  # timestamps for the last write to the primary. The resolver uses the context
  # class timestamps to determine how long to wait before reading from the
  # replica.
  #
  # By default Rails will store a last write timestamp in the session. The
  # DatabaseSelector middleware is designed as such you can define your own
  # strategy for connection switching and pass that into the middleware through
  # these configuration options.
  # config.active_record.database_selector = { delay: 2.seconds }
  # config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  # config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session

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
        env['HTTP_X_FORWARDED_FOR'] = req.forwarded_for.join(',')
      end

      # preserves access to sidekiq web
      # see https://github.com/sinatra/sinatra/blob/master/rack-protection/lib/rack/protection/ip_spoofing.rb#L17
      if env['HTTP_X_CLIENT_IP'].present?
        env['HTTP_CLIENT_IP'] = env['HTTP_X_CLIENT_IP']
      end

      @app.call(env)
    end
  end

  config.middleware.insert_before ActionDispatch::RemoteIp, FixAzureXForwardedForMiddleware

  # Add AWS IP addresses to trusted proxy list
  config.action_dispatch.trusted_proxies = [
    ActionDispatch::RemoteIp::TRUSTED_PROXIES,
    AWSIpRanges.cloudfront_ips.map { |proxy| IPAddr.new(proxy) },
  ].flatten

  config.consider_all_requests_local = true
end

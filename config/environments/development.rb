require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :notify
  config.action_mailer.notify_settings = {
    api_key: ENV.fetch("GOVUK_NOTIFY_API_KEY"),
  }
  config.action_mailer.logger = Logger.new("log/mail.log", formatter: proc { |_, _, _, msg|
    if(msg =~ /quoted-printable/)
      message = Mail::Message.new(msg)
      "\nTo: #{message.to}\n\n#{message.decoded}\n\n"
    else
      "\n#{msg}"
    end
  })

  # for default_url_options, see config/initializers/default_url_options.rb

  # Do not buffer STDOUT in Ruby. This behaviour interacts weirdly with the docker-compose
  # log output and causes logs only to be printed when an exception occurs or the process
  # exits.
  $stdout.sync = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Highlight code that enqueued background job in logs.
  config.active_job.verbose_enqueue_logs = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when a before_action's only/except options reference missing actions
  config.action_controller.raise_on_missing_callback_actions = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Logging configuration
  config.log_level = :debug
  config.logger = ActiveSupport::Logger.new(STDOUT)

  config.x.read_only_database_url = "postgres://localhost/bat_apply_development"

  # Allow use of hostname "host.docker.intenal".
  # Necessary for apply-jmeter-runner load test app to run locally.
  config.hosts << "host.docker.internal"
  # Allow Github Codespaces
  config.hosts << ".preview.app.github.dev"

  config.active_storage.service = :local
end

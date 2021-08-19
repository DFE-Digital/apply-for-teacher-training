# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Do not rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.cache_classes = true

  config.eager_load = true

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}",
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_options = {
    from: 'mail@example.com',
  }
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Forces jobs that are normally queued to Sidekiq to run immediately
  config.active_job.queue_adapter = :inline

  config.after_initialize do
    Bullet.enable = true
    Bullet.unused_eager_loading_enable = false
    Bullet.counter_cache_enable = false
    Bullet.add_safelist type: :n_plus_one_query, class_name: 'Audited::Audit', association: :user

    Bullet.raise = true # raise an error if n+1 query occurs
  end

  config.x.read_only_database_url = "postgres://localhost/bat_apply_test"
end

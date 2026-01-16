require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
require "dotenv.rb"
require "dotenv/rails"

require "./app/lib/hosting_environment"
require "./app/middlewares/redirect_to_service_gov_uk_middleware"
require "./app/middlewares/vendor_api_request_middleware"
require "./app/middlewares/service_unavailable_middleware"
require "./app/middlewares/request_identity_middleware"
require "./app/lib/rack_exceptions_app"

require_relative "../lib/modules/aws_ip_ranges"

require "grover"

module ApplyForPostgraduateTeacherTraining
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks generators rubocop omniauth])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Handle exceptions not caught by controllers, e.g. db errors
    config.exceptions_app = ->(env) { RackExceptionsApp.call(env) }

    show_previews = HostingEnvironment.test_environment?

    config.action_mailer.preview_paths = [Rails.root.join("spec/mailers/previews")]
    config.action_mailer.show_previews = show_previews

    config.view_component.preview_paths = [Rails.root.join("spec/components/previews")]
    config.view_component.show_previews = show_previews

    config.time_zone = "London"

    config.action_view.default_form_builder = GOVUKDesignSystemFormBuilder::FormBuilder

    # Make `sanitize` strip all tags by default
    # https://guides.rubyonrails.org/action_view_helpers.html#sanitizehelper
    config.action_view.sanitized_allowed_tags = %w[]

    config.i18n.exception_handler = proc { |exception| raise exception.to_exception }
    config.i18n.raise_on_missing_translations = true
    config.action_view.form_with_generates_remote_forms = false

    config.active_job.queue_adapter = :sidekiq

    config.action_controller.perform_caching = true
    config.cache_store = :memory_store

    config.i18n.load_path += Dir[Rails.root.join("config/locales/**/*.{rb,yml}")]

    config.middleware.insert_before Rack::Sendfile, RedirectToServiceGovUkMiddleware
    config.middleware.use RequestIdentityMiddleware
    config.middleware.use ServiceUnavailableMiddleware
    config.middleware.use VendorAPIRequestMiddleware
    config.middleware.use Grover::Middleware
    config.skylight.probes += %w(redis)
    config.skylight.environments = ENV["SKYLIGHT_ENABLE"].to_s == "true" ? [Rails.env] : []

    config.after_initialize do |app|
      app.routes.append { match "*path", to: "errors#not_found", via: :all }
    end

    config.analytics = config_for(:analytics)
    config.analytics_pii = config_for(:analytics_pii)
    config.analytics_blocklist = config_for(:analytics_blocklist)

    config.action_dispatch.default_headers = {
      "Feature-Policy" => "accelerometer 'none'; ambient-light-sensor: 'none', autoplay: 'none', battery: 'none', camera 'none'; display-capture: 'none', document-domain: 'none', fullscreen: 'none', geolocation 'none'; gyroscope 'none'; magnetometer 'none'; microphone 'none'; midi: 'none', payment 'none'; publickey-credentials-get: 'none', usb 'none', wake-lock: 'none', screen-wake-lock: 'none', web-share: 'none'",
      'Cache-Control' => 'no-store, no-cache',
    }

    config.action_mailer.deliver_later_queue_name = :mailers

    config.x.sections.editable = %i[
      personal_details
      contact_details
      training_with_a_disability
      interview_preferences
      equality_and_diversity
      becoming_a_teacher
      science_gcse
      efl
      work_history
      volunteering
      references
    ]
    config.x.sections.editable_window_days = 5
  end
end

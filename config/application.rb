require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
# require 'active_storage/engine'
# require 'action_text/engine'
# require 'action_mailbox/engine'
# require 'action_cable/engine'

require 'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
require 'dotenv/rails'

require './app/lib/hosting_environment'
require './app/middlewares/redirect_to_service_gov_uk_middleware'
require './app/middlewares/vendor_api_request_middleware'
require './app/middlewares/service_unavailable_middleware'
require './app/middlewares/request_identity_middleware'
require './app/lib/rack_exceptions_app'

require_relative "../lib/modules/aws_ip_ranges"

require 'pdfkit'

module ApplyForPostgraduateTeacherTraining
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Do not generate system test files.
    config.generators.system_tests = nil

    # Handle exceptions not caught by controllers, e.g. db errors
    config.exceptions_app = ->(env) { RackExceptionsApp.call(env) }

    show_previews = HostingEnvironment.test_environment?

    config.action_mailer.preview_path = Rails.root.join('spec/mailers/previews')
    config.action_mailer.show_previews = show_previews

    config.view_component.preview_paths = [Rails.root.join('spec/components/previews')]
    config.view_component.show_previews = show_previews

    config.time_zone = 'London'

    config.action_view.default_form_builder = GOVUKDesignSystemFormBuilder::FormBuilder

    config.i18n.exception_handler = Proc.new { |exception| raise exception.to_exception }
    config.i18n.raise_on_missing_translations = true
    config.action_view.form_with_generates_remote_forms = false

    config.active_job.queue_adapter = :sidekiq

    config.action_controller.perform_caching = true
    config.cache_store = :memory_store

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    config.middleware.use RequestIdentityMiddleware
    config.middleware.use ServiceUnavailableMiddleware
    config.middleware.insert_after ActionDispatch::HostAuthorization, RedirectToServiceGovUkMiddleware
    config.middleware.use VendorAPIRequestMiddleware
    config.middleware.use PDFKit::Middleware, { print_media_type: true, page_size: "A4" }, disposition: 'attachment', only: [%r[^/provider/applications/\d+]]
    config.skylight.environments = ENV['SKYLIGHT_ENABLE'].to_s == 'true' ? [Rails.env] : []

    config.after_initialize do |app|
      app.routes.append { match '*path', to: 'errors#not_found', via: :all }
    end

    config.analytics = config_for(:analytics)
    config.analytics_pii = config_for(:analytics_pii)
    config.analytics_blocklist = config_for(:analytics_blocklist)

    config.action_dispatch.default_headers = {
      'Feature-Policy' => "accelerometer 'none'; ambient-light-sensor: 'none', autoplay: 'none', battery: 'none', camera 'none'; display-capture: 'none', document-domain: 'none', fullscreen: 'none', geolocation 'none'; gyroscope 'none'; magnetometer 'none'; microphone 'none'; midi: 'none', payment 'none'; publickey-credentials-get: 'none', usb 'none', wake-lock: 'none', screen-wake-lock: 'none', web-share: 'none'",
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
    ]
  end
end

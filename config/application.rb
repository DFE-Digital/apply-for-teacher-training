require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"

require "action_view/component"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require "./app/lib/hosting_environment"

module ApplyForPostgraduateTeacherTraining
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.autoloader = :classic

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.exceptions_app = self.routes

    config.action_mailer.preview_path = "#{Rails.root}/app/mailers/previews"
    config.action_mailer.show_previews = Rails.env.development? || HostingEnvironment.qa? || HostingEnvironment.review?

    config.time_zone = 'London'

    config.action_view.default_form_builder = GOVUKDesignSystemFormBuilder::FormBuilder

    config.action_view.raise_on_missing_translations = true

    config.active_job.queue_adapter = :sidekiq
  end
end

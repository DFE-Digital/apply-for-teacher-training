require './app/lib/rack_exceptions_app'

Rails.application.configure do
  # Handle exceptions not caught by controllers, e.g. db errors
  config.exceptions_app = ->(env) { RackExceptionsApp.call(env) }
end

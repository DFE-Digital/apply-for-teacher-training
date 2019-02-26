# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

use ApplicationInsights::Rack::TrackRequest, ENV['APPINSIGHTS_INSTRUMENTATIONKEY'] if ENV['APPINSIGHTS_INSTRUMENTATIONKEY'].present?
ApplicationInsights::UnhandledException.collect(ENV['APPINSIGHTS_INSTRUMENTATIONKEY']) if ENV['APPINSIGHTS_INSTRUMENTATIONKEY'].present?

run Rails.application

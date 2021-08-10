# frozen_string_literal: true

if HostingEnvironment.test_environment? && HostingEnvironment.environment_name != 'test'
  require 'rack-mini-profiler'

  # initialization is skipped so trigger it
  Rack::MiniProfilerRails.initialize!(Rails.application)
end

if HostingEnvironment.test_environment? && HostingEnvironment.environment_name != 'test' && ENV.fetch('RACK_MINI_PROFILER', nil) == 'true'
  require 'rack-mini-profiler'

  # initialization is skipped so trigger it
  Rack::MiniProfilerRails.initialize!(Rails.application)

  Rack::MiniProfiler.config.authorization_mode = :allow_all
end

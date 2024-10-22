Rails.application.configure do
  config.skylight.probes += %w[redis]
  config.skylight.environments = ENV['SKYLIGHT_ENABLE'].to_s == 'true' ? [Rails.env] : []
end

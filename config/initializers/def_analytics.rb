Rails.application.configure do
  config.analytics = config_for(:analytics)
  config.analytics_pii = config_for(:analytics_pii)
  config.analytics_blocklist = config_for(:analytics_blocklist)
end

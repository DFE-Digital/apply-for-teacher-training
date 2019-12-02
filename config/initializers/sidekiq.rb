require 'workers/audit_trail_attribution_middleware'

redis_url = ENV.fetch('REDIS_URL')
redis_url = redis_url.gsub(/\/\d+$/, '/9') if Rails.env.test? # hardcode db to isolate test data

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
  config.server_middleware do |chain|
    chain.add Workers::AuditTrailAttributionMiddleware
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end

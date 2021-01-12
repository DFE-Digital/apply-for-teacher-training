require 'workers/audit_trail_attribution_middleware'
require './app/lib/apply_redis_connection'

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Workers::AuditTrailAttributionMiddleware
  end
end

# Configure Redis connection
sidekiq_redis_config = proc { |config|
  config.redis = { url: ApplyRedisConnection.url }
}
Sidekiq.configure_server(&sidekiq_redis_config)
Sidekiq.configure_client(&sidekiq_redis_config)

require 'sidekiq/web'
Sidekiq::Web.set :sessions, false

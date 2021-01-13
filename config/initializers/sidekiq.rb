require 'workers/audit_trail_attribution_middleware'
require './app/lib/apply_redis_connection'

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Workers::AuditTrailAttributionMiddleware
  end
end

require 'sidekiq/web'
Sidekiq::Web.set :sessions, false

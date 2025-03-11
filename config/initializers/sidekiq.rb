require 'workers/audit_trail_attribution_middleware'

# strict_args required for Sidekiq 7.0 upgrade
# https://github.com/sidekiq/sidekiq/blob/main/docs/7.0-Upgrade.md#strict-arguments
Sidekiq.strict_args!

Sidekiq.configure_server do |config|
  # https://github.com/redis-rb/redis-client#configuration
  config.redis = {
    url: ENV.fetch('REDIS_URL') { 'redis://localhost:6379/0' },
    timeout: 10,
  }

  config.server_middleware do |chain|
    chain.add Workers::AuditTrailAttributionMiddleware
  end

  Yabeda::Prometheus::Exporter.start_metrics_server!
end

require 'sidekiq/web'

require 'workers/audit_trail_attribution_middleware'

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Workers::AuditTrailAttributionMiddleware
  end

  Yabeda::Prometheus::Exporter.start_metrics_server!
end

require 'sidekiq/web'

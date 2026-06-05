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

require 'redis/connection/ruby'

class Redis
  module Connection
    class Ruby
      def read
        line = @sock.gets
        reply_type = line.slice!(0, 1)
        format_reply(reply_type, line)
      rescue Errno::EAGAIN
        raise TimeoutError
      rescue OpenSSL::SSL::SSLError => e
        if e.message.match?(/SSL_read: unexpected eof while reading/i) || e.message.match?(/tls_retry_write_records failure/i)
          raise EOFError, e.message
        else
          raise
        end
      end
    end
  end
end

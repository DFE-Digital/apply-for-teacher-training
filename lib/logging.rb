class Logging
  def self.set(config)
    config.log_level = :info # :debug does not make sense with lograge + logstash

    # Use default logging formatter so that PID and timestamp are not suppressed.
    config.log_formatter = ::Logger::Formatter.new

    # Prepend all STDOUT log lines with the following tags:
    config.log_tags = [ :request_id ]

    # Make stdout_logger the standard Rails logger
    stdout_logger = ActiveSupport::Logger.new(STDOUT)
    stdout_logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(stdout_logger)

    # Use lograge for one log line per request, in json format for Logstash
    config.lograge.enabled = true # lograge uses one log line per request
    config.lograge.formatter = Lograge::Formatters::Logstash.new

    if ENV['LOGSTASH_ENABLE'] == 'true'
      tcp_logger = LogStashLogger.new(type: :tcp,
                                      host: ENV.fetch('LOGSTASH_HOST'),
                                      port: ENV.fetch('LOGSTASH_PORT'),
                                      ssl_enable: ENV.fetch('LOGSTASH_SSL') == 'true')

      # tell Rails logger to broadcast logs to additional location
      config.logger.extend(ActiveSupport::Logger.broadcast(tcp_logger))
    end
  end
end

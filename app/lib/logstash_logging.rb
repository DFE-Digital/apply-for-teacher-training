require 'request_store_rails'

class LogstashLogging
  DOMAIN_FOR_LOGS = Rails.env.production? ? HostingEnvironment.hostname : Socket.gethostname
  SERVICE_TYPE = ENV['SERVICE_TYPE'] # e.g. web, worker or clock

  def self.enable(rails_config)
    # Add custom attributes to the log (domain, params etc.)
    LogStashLogger.configure do |logstash_config|
      logstash_config.customize_event do |event|
        event['domain'] = DOMAIN_FOR_LOGS
        event['service'] = SERVICE_TYPE
        params = RequestLocals.fetch(:params) {} # block is required
        if params
          event['params'] = params # add query params to the logs, if available
        end
        add_identity_fields(event)
        add_sidekiq_fields(event)
      end
    end

    # Use lograge to force Rails use one log line per request, in Logstash json format
    lograge_config(rails_config)

    # Log destination: log to STDOUT, plus to a remote Logstash server, if required
    logstash_logger = \
      if ENV['LOGSTASH_REMOTE'] == 'true'
        LogStashLogger.new(
          type: :multi_delegator,
          outputs: [
            { type: :stdout }, # good practice for Docker containers
            {
              type: :tcp,
              host: ENV.fetch('LOGSTASH_HOST'),
              port: ENV.fetch('LOGSTASH_PORT'),
              ssl_enable: ENV.fetch('LOGSTASH_SSL') == 'true',
            },
          ],
        )
      else
        LogStashLogger.new(type: :stdout)
      end

    # Make logstash_logger the default logger for Rails, Sidekiq and clockwork
    rails_config.logger = logstash_logger
    Sidekiq.logger = logstash_logger
    Clockwork.configure { |config| config[:logger] = logstash_logger }
  end

  def self.lograge_config(rails_config)
    rails_config.lograge.enabled = true # lograge uses one log line per request
    rails_config.lograge.base_controller_class = [
      'ActionController::Base',
      'ActionController::API', # API controllers inherit from ActionController::API
    ]
    # Add exception to the lograge log format
    rails_config.lograge.custom_options = lambda do |event|
      { exception: event.payload[:exception] } # ["ExceptionClass", "the message"]
    end
    rails_config.lograge.formatter = Lograge::Formatters::Logstash.new
  end

  def self.add_identity_fields(event)
    identity_hash = RequestLocals.fetch(:identity) {} # block is required
    identity_hash.each { |key, val| event[key] = val } if identity_hash
  end

  def self.add_sidekiq_fields(event)
    tid = Thread.current['sidekiq_tid']
    if tid.present?
      ctx = Sidekiq::Context.current
      event['tid'] = tid
      event['ctx'] = ctx
    end
  end
end

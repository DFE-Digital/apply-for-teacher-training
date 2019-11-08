require 'request_store_rails'

class LogstashLogging
  DOMAIN_FOR_LOGS = Rails.env.production? ? HostingEnvironment.hostname : Socket.gethostname
  SERVICE_NAME = ENV['SERVICE_NAME'] # e.g. web, worker or clock

  def self.add_id_fields(event)
    candidate_id = RequestLocals.fetch(:candidate_id) { nil }
    if candidate_id
      event['candidate_id'] = candidate_id
    end
    vendor_api_token_id = RequestLocals.fetch(:vendor_api_token_id) { nil }
    # TODO: is there a vendor_id we should also log?
    if vendor_api_token_id
      event['vendor_api_token_id'] = vendor_api_token_id
      event['provider_id'] = RequestLocals.fetch(:provider_id) { nil }
    end
  end

  def self.add_sidekiq_fields(event)
    tid = Thread.current['sidekiq_tid']
    if !tid.blank?
      ctx = Sidekiq::Context.current
      event['tid'] = tid
      event['ctx'] = ctx
    end
  end

  def self.enable(rails_config)
    # Add domain, params etc. to the logs
    LogStashLogger.configure do |logstash_config|
      logstash_config.customize_event do |event|
        event['domain'] = DOMAIN_FOR_LOGS
        event['service'] = SERVICE_NAME
        params = RequestLocals.fetch(:params) { nil }
        if params
          event['params'] = params # add query params to the logs, if available
        end
        add_id_fields(event)
        add_sidekiq_fields(event)
      end
    end

    # Use lograge to force Rails use one log line per request, in Logstash json format
    rails_config.lograge.enabled = true # lograge uses one log line per request
    rails_config.lograge.base_controller_class = [
      'ActionController::Base',
      'ActionController::API', # API controllers inherit from ActionController::API
      'Sidekiq::Worker',
      'Clockwork',
    ]
    # Add exception to the lograge log format
    rails_config.lograge.custom_options = lambda do |event|
      { exception: event.payload[:exception] } # ["ExceptionClass", "the message"]
    end
    rails_config.lograge.formatter = Lograge::Formatters::Logstash.new

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

    rails_config.logger = logstash_logger # Make logstash_logger the default Rails logger
    Sidekiq.logger = logstash_logger # Same for Sidekiq
    Clockwork.configure { |config| config[:logger] = logstash_logger } # Same for clockwork
  end
end

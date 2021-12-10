# frozen_string_literal: true

require 'request_store_rails'
return unless defined? SemanticLogger

class CustomLogFormatter < SemanticLogger::Formatters::Raw
  def call(log, logger)
    super(log, logger)
    add_service_type
    add_job_data
    remove_post_params
    hash.to_json
  end

private

  def add_service_type
    hash['domain'] = HostingEnvironment.hostname
    hash['environment'] = HostingEnvironment.environment_name
    hash['hosting_environment'] = HostingEnvironment.environment_name
    hash['service'] = ENV['SERVICE_TYPE']
  end

  def add_job_data
    hash[:job_id] = RequestStore.store[:job_id] if RequestStore.store[:job_id].present?
    hash[:job_queue] = RequestStore.store[:job_queue] if RequestStore.store[:job_queue].present?
    tid = Thread.current['sidekiq_tid']
    if tid.present?
      ctx = Sidekiq::Context.current
      hash['tid'] = tid
      hash['ctx'] = ctx
    end
  end

  def remove_post_params
    if method_is_post_or_put_or_patch? && hash.dig(:payload, :params).present?
      hash[:payload][:params].clear
    end
  end

  def method_is_post_or_put_or_patch?
    hash.dig(:payload, :method).in? %w[PUT POST PATCH]
  end
end

rails_config = Rails.application.config
log_formatter = if HostingEnvironment.development?
                  rails_config.rails_semantic_logger.format
                else
                  CustomLogFormatter.new
                end
Clockwork.configure { |config| config[:logger] = SemanticLogger[Clockwork] if defined?(Clockwork) }
SemanticLogger.add_appender(io: STDOUT, level: rails_config.log_level, formatter: log_formatter)
rails_config.logger.info('Application logging to STDOUT')

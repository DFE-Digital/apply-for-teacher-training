# frozen_string_literal: true

require 'request_store_rails'
return unless defined? SemanticLogger

class CustomLogFormatter < SemanticLogger::Formatters::Raw
  def call(log, logger)
    super(log, logger)

    # Add custom fields
    hash['domain'] = HostingEnvironment.hostname
    hash['environment'] = HostingEnvironment.environment_name
    hash['hosting_environment'] = HostingEnvironment.environment_name

    if (job_id = Thread.current[:job_id])
      hash['job_id'] = job_id
    end
    if (job_queue = Thread.current[:job_queue])
      hash['job_queue'] = job_queue
    end
    tid = Thread.current['sidekiq_tid']
    if tid.present?
      ctx = Sidekiq::Context.current
      hash['tid'] = tid
      hash['ctx'] = ctx
    end

    # Remove post parameters if it's a PUT, POST, or PATCH request
    if method_is_post_or_put_or_patch?
      hash[:payload] ||= {}
      hash[:payload][:params] = {} if hash[:payload].nil?
    end

    hash.to_json
  end

private

  def method_is_post_or_put_or_patch?
    hash.dig(:payload, :method).in? %w[PUT POST PATCH]
  end
end

if HostingEnvironment.development?
  SemanticLogger.add_appender(
    file_name: Rails.root.join('log/development.log').to_s,
    level: Rails.application.config.log_level,
    formatter: CustomLogFormatter.new,
  )
else
  Clockwork.configure { |config| config[:logger] = SemanticLogger[Clockwork] if defined?(Clockwork) }
  SemanticLogger.add_appender(
    io: STDOUT,
    level: Rails.application.config.log_level,
    formatter: CustomLogFormatter.new,
  )
  Rails.logger.info('Application logging to STDOUT')
end

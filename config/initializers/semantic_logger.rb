# frozen_string_literal: true

return unless defined? SemanticLogger

require_dependency Rails.root.join('app/lib/custom_log_formatter')

unless Rails.env.local?
  Clockwork.configure { |config| config[:logger] = SemanticLogger[Clockwork] if defined?(Clockwork) }
  SemanticLogger.add_appender(
    io: STDOUT,
    level: Rails.application.config.log_level,
    formatter: CustomLogFormatter.new,
  )
  Rails.logger.info('Application logging to STDOUT')
end

## To avoid logging sensitive data on "subjects" and "to":
## See more details on: https://github.com/reidmorrison/rails_semantic_logger/issues/230
module RailsSemanticLogger
  module ActionMailer
    class LogSubscriber < ::ActiveSupport::LogSubscriber
      class EventFormatter
        def payload
          {}.tap do |h|
            h[:event_name]         = event.name
            h[:mailer]             = mailer
            h[:action]             = action
            h[:message_id]         = event.payload[:message_id]
            h[:perform_deliveries] = event.payload[:perform_deliveries]
            h[:subject]            = '[FILTERED]'
            h[:to]                 = '[FILTERED]'
            h[:from]               = event.payload[:from]
            h[:bcc]                = event.payload[:bcc]
            h[:cc]                 = event.payload[:cc]
            h[:date]               = date
            h[:duration]           = event.duration.round(2) if log_duration?
            h[:args]               = '[FILTERED]'
          end
        end
      end
    end
  end
end

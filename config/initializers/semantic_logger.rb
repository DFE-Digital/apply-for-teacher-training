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
          filtered_params = Rails.application.config.filter_parameters
          parameter_filter = ActiveSupport::ParameterFilter.new(filtered_params)

          {}.tap do |h|
            h[:event_name]         = event.name
            h[:mailer]             = mailer
            h[:action]             = action
            h[:message_id]         = event.payload[:message_id]
            h[:perform_deliveries] = event.payload[:perform_deliveries]
            h[:subject]            = parameter_filter.filter(subject: event.payload[:subject])[:subject]
            h[:to]                 = parameter_filter.filter(to: event.payload[:to])[:to]
            h[:from]               = parameter_filter.filter(from: event.payload[:from])[:from]
            h[:bcc]                = parameter_filter.filter(bcc: event.payload[:bcc])[:bcc]
            h[:cc]                 = parameter_filter.filter(cc: event.payload[:cc])[:cc]
            h[:date]               = date
            h[:duration]           = event.duration.round(2) if log_duration?
            h[:args]               = parameter_filter.filter(args: event.payload[:args])[:args]
          end
        end
      end
    end
  end
end

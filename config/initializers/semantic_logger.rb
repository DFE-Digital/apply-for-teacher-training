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
            h[:event_name]         = parameter_filter.filter_param('mailer.event_name', event.name)
            h[:mailer]             = parameter_filter.filter_param('mailer.mailer', mailer)
            h[:action]             = parameter_filter.filter_param('mailer.action', action)
            h[:message_id]         = parameter_filter.filter_param('mailer.message_id', event.payload[:message_id])
            h[:perform_deliveries] = parameter_filter.filter_param('mailer.perform_deliveries', event.payload[:perform_deliveries])
            h[:subject]            = parameter_filter.filter_param('mailer.subject', event.payload[:subject])
            h[:to]                 = parameter_filter.filter_param('mailer.to', event.payload[:to])
            h[:from]               = parameter_filter.filter_param('mailer.from', event.payload[:from])
            h[:bcc]                = parameter_filter.filter_param('mailer.bcc', event.payload[:bcc])
            h[:cc]                 = parameter_filter.filter_param('mailer.cc', event.payload[:cc])
            h[:date]               = parameter_filter.filter_param('mailer.date', date)
            h[:duration]           = parameter_filter.filter_param('mailer.duration', event.duration.round(2)) if log_duration?
            h[:args]               = parameter_filter.filter_param('mailer.args', event.payload[:args])
          end
        end
      end
    end
  end
end

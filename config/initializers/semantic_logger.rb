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
          FilteredMailPayload.new(self, event).filtered_payload
        end
      end
    end
  end
end

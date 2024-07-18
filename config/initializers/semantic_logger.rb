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

return unless defined? SemanticLogger

unless Rails.env.local?
  Clockwork.configure { |config| config[:logger] = SemanticLogger[Clockwork] if defined?(Clockwork) }
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

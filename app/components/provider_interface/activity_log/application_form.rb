module ProviderInterface
  module ActivityLog
    class ApplicationForm
      attr_reader :event, :application_choice
      def initialize(event:)
        @event = event
      end

      def event_description
        section = ::ApplicationForm::ColumnSectionMapping.by_column(event.audit.audited_changes.keys.first)

        "#{section.humanize} edited"
      end
    end
  end
end

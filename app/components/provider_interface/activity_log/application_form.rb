module ProviderInterface
  module ActivityLog
    class ApplicationForm
      attr_reader :event, :section
      def initialize(event:)
        @event = event
        @section = ::ApplicationForm::ColumnSectionMapping.by_column(event.audit.audited_changes.keys.first)
      end

      def event_description
        "#{section.humanize} edited"
      end
    end
  end
end

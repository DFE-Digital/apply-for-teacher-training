module ProviderInterface
  module ActivityLog
    class ApplicationForm
      attr_reader :event, :section
      def initialize(event:)
        @event = event
        @section = ::ApplicationForm::ColumnSectionMapping.by_column(event.audit.audited_changes.keys.first)
      end

      def event_description
        I18n.t('provider_interface.activity_log.application_form.edited', section: section.humanize)
      end

      def link
        application_link("#{section.tr('_', '-')}-section")
      end

      def application_link(anchor = nil)
        {
          url: routes.provider_interface_application_choice_path(event.application_choice, anchor:),
          text: 'View application',
        }
      end

      def routes
        @_routes ||= Rails.application.routes.url_helpers
      end
    end
  end
end

module ProviderInterface
  module ActivityLog
    class Interview
      attr_reader :event, :application_choice
      def initialize(event:)
        @event = event
        @application_choice = @event.audit.associated
      end

      def event_description
        return I18n.t('provider_interface.activity_log.interview.create', candidate:, user:) if event.audit.action == 'create'
        return I18n.t('provider_interface.activity_log.interview.cancelled_at', candidate:, user:) if event.audit.audited_changes.key?('cancelled_at')

        I18n.t('provider_interface.activity_log.interview.updated', candidate:, user:)
      end

      def user
        event.user_full_name
      end

      def candidate
        event.candidate_full_name
      end
    end
  end
end

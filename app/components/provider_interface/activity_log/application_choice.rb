module ProviderInterface
  module ActivityLog
    class ApplicationChoice
      attr_reader :event, :application_choice
      delegate :changes, to: :event
      delegate :t, to: :I18n

      def initialize(event:)
        @event = event
        @application_choice = @event.audit.auditable
      end

      def event_description
        match_description || rejected_description || declined_description || other_description
      end

    private

      def other_description
        if changes['reject_by_default_feedback_sent_at'].present?
          t('provider_interface.activity_log.application_choice.reject_by_default_feedback_sent', candidate:, user:)
        elsif changes['offer_changed_at'].present?
          t('provider_interface.activity_log.application_choice.offer_changed_at', candidate:, user:)
        elsif changes['course_changed_at'].present?
          t('provider_interface.activity_log.application_choice.course_changed_at', candidate:, user:)
        elsif status == 'inactive'
          t('provider_interface.activity_log.application_choice.inactive', candidate:)
        end
      end

      def declined_description
        return unless status == 'declined'

        if application_choice.declined_by_default
          t('provider_interface.activity_log.application_choice.declined_by_default', candidate:)
        else
          t('provider_interface.activity_log.application_choice.declined', candidate:)
        end
      end

      def rejected_description
        return unless status == 'rejected'

        if application_choice.rejected_by_default
          t('provider_interface.activity_log.application_choice.rejected_by_default', candidate:)
        else
          t('provider_interface.activity_log.application_choice.rejected', candidate:, user:)
        end
      end

      def match_description
        case status
        when 'awaiting_provider_decision', 'withdrawn', 'pending_conditions'
          t("provider_interface.activity_log.application_choice.#{status}", candidate:)
        when 'offer', 'offer_withdrawn', 'recruited', 'offer_deferred', 'conditions_not_met'
          t("provider_interface.activity_log.application_choice.#{status}", candidate:, user:)
        end
      end

      def user
        @event.user_full_name
      end

      def candidate
        @event.candidate_full_name
      end

      def status
        @event.application_status_at_event
      end
    end
  end
end

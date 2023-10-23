module ProviderInterface
  module ActivityLog
    class ApplicationChoice
      attr_reader :event, :application_choice
      delegate :changes, to: :event

      def initialize(event:)
        @event = event
        @application_choice = @event.audit.auditable
      end

      def event_description
        user = event.user_full_name
        candidate = event.candidate_full_name

        case event.application_status_at_event
        when 'awaiting_provider_decision'
          "Application received from #{candidate}"
        when 'withdrawn'
          "#{candidate} withdrew their application"
        when 'rejected'
          if application_choice.rejected_by_default
            "#{candidate}’s application was automatically rejected"
          else
            "#{user} rejected #{candidate}’s application"
          end
        when 'offer'
          "#{user} made an offer to #{candidate}"
        when 'offer_withdrawn'
          "#{user} withdrew #{candidate}’s offer"
        when 'declined'
          if application_choice.declined_by_default
            "#{candidate}’s offer was automatically declined"
          else
            "#{candidate} declined an offer"
          end
        when 'pending_conditions'
          "#{candidate} accepted an offer"
        when 'conditions_not_met'
          "#{user} marked #{candidate}’s offer conditions as not met"
        when 'recruited'
          "#{user} marked #{candidate}’s offer conditions as all met"
        when 'offer_deferred'
          "#{user} deferred #{candidate}’s offer"
        else
          if changes['reject_by_default_feedback_sent_at'].present?
            "#{user} sent feedback to #{candidate}"
          elsif changes['offer_changed_at'].present?
            "#{user} changed the offer made to #{candidate}"
          elsif changes['course_changed_at'].present?
            "#{user} updated #{candidate}’s course"
          end
        end
      end
    end
  end
end

module CandidateInterface
  module ContinuousApplications
    class ApplicationChoiceStatusTagComponent < ::CandidateInterface::ApplicationStatusTagComponent
      def text
        t("continuous_applications.candidate_application_states.#{application_choice.status}")
      end

      def colour
        case application_choice.status
        when 'unsubmitted'
          'blue'
        when 'awaiting_provider_decision', 'inactive'
          'purple'
        when 'conditions_not_met', 'declined', 'cancelled'
          'red'
        when 'offer', 'pending_conditions', 'recruited'
          'green'
        when 'offer_withdrawn'
          'pink'
        when 'offer_deferred', 'application_not_sent', 'interviewing'
          'yellow'
        when 'rejected', 'withdrawn'
          'orange'
        else
          raise "You need to define a colour for the #{status} state"
        end
      end
    end
  end
end

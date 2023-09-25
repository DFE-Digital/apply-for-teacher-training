module CandidateInterface
  class ApplicationStatusTagComponent < ViewComponent::Base
    delegate :status, to: :application_choice

    def initialize(application_choice:, display_info_text: true)
      @application_choice = application_choice
      @display_info_text = display_info_text
    end

    def text
      t("candidate_application_states.#{application_choice.status}")
    end

    def colour
      case application_choice.status
      when 'unsubmitted'
        'grey'
      when 'awaiting_provider_decision', 'interviewing'
        'purple'
      when 'offer'
        'turquoise'
      when 'rejected', 'offer_withdrawn', 'application_not_sent'
        'pink'
      when 'pending_conditions'
        'blue'
      when 'recruited'
        'green'
      when 'declined', 'withdrawn', 'cancelled'
        'orange'
      when 'conditions_not_met'
        'red'
      when 'offer_deferred', 'inactive'
        'yellow'
      else
        raise "You need to define a colour for the #{status} state"
      end
    end

  private

    attr_reader :application_choice
  end
end

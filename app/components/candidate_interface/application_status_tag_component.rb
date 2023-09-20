module CandidateInterface
  class ApplicationStatusTagComponent < ViewComponent::Base
    delegate :status, to: :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
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

    def days_since_submission(application_form)
      return if application_form.submitted_at.nil?

      (Time.zone.now.to_date - application_form.submitted_at.to_date).to_i
    end

  private

    attr_reader :application_choice
  end
end

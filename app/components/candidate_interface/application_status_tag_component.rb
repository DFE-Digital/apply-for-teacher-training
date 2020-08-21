module CandidateInterface
  class ApplicationStatusTagComponent < ViewComponent::Base
    validates :application_choice, presence: true
    delegate :status, to: :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def text
      t("candidate_application_states.#{application_choice.status}")
    end

    def type
      case application_choice.status
      when 'unsubmitted', 'awaiting_references', 'application_complete'
        :grey
      when 'awaiting_provider_decision'
        :purple
      when 'offer'
        :turquoise
      when 'rejected', 'offer_withdrawn'
        :pink
      when 'pending_conditions'
        :blue
      when 'recruited'
        :green
      when 'declined', 'withdrawn', 'cancelled'
        :orange
      when 'conditions_not_met'
        :red
      when 'enrolled'
        :default
      else
        raise "You need to define a colour for the #{status} state"
      end
    end

  private

    attr_reader :application_choice
  end
end

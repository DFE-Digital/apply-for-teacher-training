module ProviderInterface
  class ApplicationStatusTagComponent < ViewComponent::Base
    delegate :status, to: :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def text
      I18n.t!("provider_application_states.#{status}")
    end

    def colour
      case status
      when 'unsubmitted', 'cancelled', 'application_not_sent'
        # will never be visible to the provider
      when 'awaiting_provider_decision'
        'purple'
      when 'interviewing', 'offer_deferred'
        'yellow'
      when 'offer'
        'turquoise'
      when 'pending_conditions'
        'blue'
      when 'recruited'
        'green'
      when 'rejected', 'conditions_not_met', 'offer_withdrawn'
        'orange'
      when 'declined', 'withdrawn'
        'red'
      else
        raise "You need to define a colour for the #{status} state"
      end
    end

  private

    attr_reader :application_choice
  end
end

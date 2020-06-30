module ProviderInterface
  class ApplicationStatusTagComponent < ViewComponent::Base
    validates :application_choice, presence: true
    delegate :status, to: :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def text
      return t('provider_application_states.offer_withdrawn') if application_choice.offer_withdrawn?

      I18n.t!("provider_application_states.#{status}")
    end

    def type
      case status
      when 'awaiting_provider_decision'
        :purple
      when 'offer'
        :turquoise
      when 'pending_conditions'
        :blue
      when 'recruited'
        :green
      when 'rejected', 'conditions_not_met'
        :orange
      when 'declined', 'withdrawn'
        :red
      else
        raise "You need to define a colour for the #{status} state"
      end
    end

  private

    attr_reader :application_choice
  end
end

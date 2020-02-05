module ProviderInterface
  class ApplicationStatusTagComponent < ActionView::Component::Base
    validates :application_choice, presence: true
    delegate :application_status, to: :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def text
      I18n.t!("provider_application_states.#{application_status}")
    end

    def type
      case application_status
      when 'awaiting_provider_decision'
        :purple
      when 'offer'
        :green
      when 'rejected'
        :red
      when 'pending_conditions'
        :turquoise
      when 'declined' || 'offer_withdrawn'
        :orange
      when 'enrolled'
        :blue
      end
    end

  private

    attr_reader :application_choice
  end
end

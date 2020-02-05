module ProviderInterface
  class ApplicationStatusTagComponent < ActionView::Component::Base
    validates :application_choice, presence: true
    delegate :status, to: :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def text
      I18n.t!("provider_application_states.#{status}")
    end

    def type
      case status
      when 'awaiting_provider_decision'
        :purple
      when 'offer'
        :green
      when 'rejected'
        :red
      when 'pending_conditions'
        :turquoise
      when 'declined'
        :orange
      when 'enrolled'
        :blue
      when 'recruited'
        :green
      when 'conditions_not_met'
        :red
      when 'withdrawn'
        :orange
      end
    end

  private

    attr_reader :application_choice
  end
end

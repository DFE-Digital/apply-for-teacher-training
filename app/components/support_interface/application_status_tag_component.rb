# TODO: dedupe with the ProviderInterface counterpart
module SupportInterface
  class ApplicationStatusTagComponent < ActionView::Component::Base
    validates :application_choice, presence: true
    delegate :status, to: :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def text
      I18n.t!("application_states.#{status}.name")
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
      end
    end

  private

    attr_reader :application_choice
  end
end

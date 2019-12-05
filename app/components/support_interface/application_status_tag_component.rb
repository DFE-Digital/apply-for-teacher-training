# TODO: dedupe with the ProviderInterface counterpart
module SupportInterface
  class ApplicationStatusTagComponent < ActionView::Component::Base
    validates :application_choice, presence: true
    delegate :status, to: :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def text
      I18n.t!("support_application_states.#{status}")
    end

    def type
      case status
      when 'awaiting_provider_decision'
        :primary_unfilled
      when 'offer'
        :info_unfilled
      when 'rejected'
        :danger
      when 'pending_conditions'
        :info
      when 'declined'
        :warning
      else
        ''
      end
    end

  private

    attr_reader :application_choice
  end
end

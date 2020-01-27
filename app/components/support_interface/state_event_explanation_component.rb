module SupportInterface
  class StateEventExplanationComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :from_state, :event

    def initialize(from_state:, event:)
      @from_state = from_state
      @event = event
    end

    def emails_sent_from_event
      if I18n.exists?("events.#{from_state}-#{event.name}.emails")
        I18n.t!("events.#{from_state}-#{event.name}.emails")
      else
        []
      end
    end

    def transitions_to
      event.transitions_to.to_s
    end

    def by
      I18n.t!("events.#{from_state}-#{event}.by")
    end

    def description
      I18n.t!("events.#{from_state}-#{event.name}.description")
    end
  end
end

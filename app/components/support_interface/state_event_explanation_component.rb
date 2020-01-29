module SupportInterface
  class StateEventExplanationComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :from_state, :event, :namespace, :machine

    def initialize(from_state:, event:, machine:)
      @from_state = from_state
      @event = event
      @machine = machine
      @namespace = machine.i18n_namespace
    end

    def emails_sent_from_event
      if I18n.exists?("#{namespace}events.#{from_state}-#{event.name}.emails")
        I18n.t!("#{namespace}events.#{from_state}-#{event.name}.emails")
      else
        []
      end
    end

    def human_transitions_to
      I18n.t!("#{namespace}application_states.#{transitions_to}.name")
    end

    def transitions_to
      event.transitions_to.to_s
    end

    def by
      I18n.t!("#{namespace}events.#{from_state}-#{event}.by")
    end

    def description
      I18n.t!("#{namespace}events.#{from_state}-#{event.name}.description")
    end
  end
end

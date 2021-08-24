class StateEventExplanationComponent < ViewComponent::Base
  include ViewHelper

  attr_reader :from_state, :event, :namespace, :machine, :development_details

  def initialize(from_state:, event:, machine:, development_details:)
    @from_state = from_state
    @event = event
    @machine = machine
    @development_details = development_details
    @namespace = machine.i18n_namespace
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

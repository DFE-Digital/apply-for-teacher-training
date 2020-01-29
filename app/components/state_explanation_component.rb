class StateExplanationComponent < ActionView::Component::Base
  include ViewHelper

  attr_reader :state, :namespace, :machine, :development_details

  def initialize(state:, machine:, development_details: false)
    @state = state
    @machine = machine
    @development_details = development_details
    @namespace = machine.i18n_namespace
  end

  def state_name
    state.name.to_s
  end

  def human_state_name
    I18n.t!("#{namespace}application_states.#{state_name}.name")
  end

  def state_description
    I18n.t!("#{namespace}application_states.#{state_name}.description")
  end
end

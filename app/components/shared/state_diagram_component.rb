class StateDiagramComponent < ApplicationComponent
  attr_accessor :machine, :ignore_states

  def initialize(machine:, ignore_states: [])
    @machine = machine
    @ignore_states = ignore_states
  end
end

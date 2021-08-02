class StateDiagramComponent < ViewComponent::Base
  def initialize(machine:)
    @machine = machine
  end
end

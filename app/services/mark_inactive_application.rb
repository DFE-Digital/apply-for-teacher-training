class MarkInactiveApplication
  attr_accessor :application_choice
  attr_reader :state_change

  def initialize(application_choice:)
    @application_choice = application_choice
    @state_change = ApplicationStateChange.new(application_choice)
  end

  def call
    @state_change.inactivate!
  end
end

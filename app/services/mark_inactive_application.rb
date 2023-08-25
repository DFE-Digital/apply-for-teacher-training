class MarkInactiveApplication
  attr_accessor :application_choice
  attr_reader :state_change

  def initialize(application_choice:)
    @application_choice = application_choice
    @state_change = ApplicationStateChange.new(application_choice)
  end

  def call
    ActiveRecord::Base.transaction do
      @state_change.inactivate!
      application_choice.touch(:inactive_at)
    end
  end
end

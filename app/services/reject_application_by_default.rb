class RejectApplicationByDefault
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    ApplicationStateChange.new(application_choice).reject_application!
  end
end

class RejectApplicationByDefault
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    #TODO: Do we need to include some other flag here to distinguish
    #applications that have been auto-rejected versus those that were
    #explicitly rejected by the provider?
    ApplicationStateChange.new(application_choice).reject_application!
  end
end

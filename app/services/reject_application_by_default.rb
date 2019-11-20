class RejectApplicationByDefault
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    ActiveRecord::Base.transaction do
      application_choice.update(rejected_by_default: true)
      ApplicationStateChange.new(application_choice).reject_application!
      StateChangeNotifier.call(:reject_application_by_default, application_choice: application_choice)
    end
  end
end

# This worker will be scheduled to run nightly
class SendApplicationToProvider
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    return false unless application_choice.application_complete?

    ActiveRecord::Base.transaction do
      application_choice.update!(sent_to_provider_at: Time.zone.now)
      SetRejectByDefault.new(application_choice).call
      ApplicationStateChange.new(application_choice).send_to_provider!
    end

    StateChangeNotifier.call(:send_application_to_provider, application_choice: application_choice)
    SendNewApplicationEmailToProvider.new(application_choice: application_choice).call
  end
end

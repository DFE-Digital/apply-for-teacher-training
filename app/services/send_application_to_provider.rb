class SendApplicationToProvider
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    return false unless ApplicationStateChange::STATES_THAT_MAY_BE_SENT_TO_PROVIDER.include?(application_choice.status.to_sym)

    ActiveRecord::Base.transaction do
      application_choice.update!(sent_to_provider_at: Time.zone.now)
      SetRejectByDefault.new(application_choice).call
      ApplicationStateChange.new(application_choice).send_to_provider!
    end

    StateChangeNotifier.call(:send_application_to_provider, application_choice: application_choice)
    SendNewApplicationEmailToProvider.new(application_choice: application_choice).call
  end
end

class SendNewApplicationEmailToProvider
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    return false unless application_choice.awaiting_provider_decision?

    application_choice.provider.provider_users.each do |provider_user|
      ProviderMailer.application_submitted(provider_user, application_choice).deliver_now
    end
  end
end

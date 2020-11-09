class SendApplicationToProvider
  class ApplicationNotReadyToSendError < RuntimeError; end

  attr_accessor :application_choice

  def self.call(application_choice)
    new(application_choice: application_choice).call
  end

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    unless application_choice.unsubmitted?
      raise ApplicationNotReadyToSendError, "Tried to send an application in the #{application_choice.status} state to a provider"
    end

    ActiveRecord::Base.transaction do
      application_choice.update!(sent_to_provider_at: Time.zone.now)
      SetRejectByDefault.new(application_choice).call
      ApplicationStateChange.new(application_choice).send_to_provider!
    end

    SendNewApplicationEmailToProvider.new(application_choice: application_choice).call
  end
end

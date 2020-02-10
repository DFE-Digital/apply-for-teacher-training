class SendChaseEmailToProvidersWorker
  include Sidekiq::Worker

  def perform
    return unless FeatureFlag.active?('automated_provider_chaser')

    GetApplicationFormsWaitingForProviderDecision.call.each do |application_choice|
      SendChaseEmailToProvider.call(application_choice: application_choice)
    end
  end
end

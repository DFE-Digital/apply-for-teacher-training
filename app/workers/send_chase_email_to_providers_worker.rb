class SendChaseEmailToProvidersWorker
  include Sidekiq::Worker
  include SafePerformAsync

  def perform
    GetApplicationFormsWaitingForProviderDecision.call.each do |application_choice|
      SendChaseEmailToProvider.call(application_choice: application_choice)
    end
  end
end

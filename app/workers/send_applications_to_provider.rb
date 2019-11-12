# This worker will be scheduled to run nightly
class SendApplicationsToProvider
  include Sidekiq::Worker

  def perform(*)
    GetApplicationChoicesReadyToSendToProvider.call.each do |application_choice|
      ApplicationStateChange.new(application_choice).send_to_provider!
    end
  end
end

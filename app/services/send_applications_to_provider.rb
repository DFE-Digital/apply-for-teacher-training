# This service class will be called as a background job, scheduled to run nightly
class SendApplicationsToProvider
  def call
    GetApplicationChoicesReadyToSendToProvider.call.each do |application_choice|
      ApplicationStateChange.new(application_choice).send_to_provider!
    end
  end
end

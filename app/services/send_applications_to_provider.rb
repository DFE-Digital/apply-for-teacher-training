# This worker will be scheduled to run nightly
class SendApplicationsToProvider
  def call
    GetApplicationChoicesReadyToSendToProvider.call.each do |application_choice|
      SendApplicationToProvider.new(application_choice: application_choice).call
    end
  end
end

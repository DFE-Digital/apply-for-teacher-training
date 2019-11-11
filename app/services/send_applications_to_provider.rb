class SendApplicationsToProvider
  def call
    ApplicationChoice.ready_to_send_to_provider.each do |application_choice|
      ApplicationStateChange.new(application_choice).send_to_provider!
    end
  end
end

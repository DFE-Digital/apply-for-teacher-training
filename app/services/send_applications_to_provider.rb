class SendApplicationsToProvider
  def call
    GetApplicationFormsReadyToSendToProviders.call.each do |application_form|
      application_form
        .application_choices
        .where(status: ApplicationStateChange::STATES_THAT_MAY_BE_SENT_TO_PROVIDER).each do |choice|
          SendApplicationToProvider.new(application_choice: choice).call
        end

      CandidateMailer.application_sent_to_provider(application_form).deliver_later
    end
  end
end

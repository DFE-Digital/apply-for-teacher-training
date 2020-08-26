class SendApplicationsToProvider
  def call
    GetApplicationFormsReadyToSendToProviders.call.each do |application_form|
      application_choices = application_form.application_choices
      cancelled_choices = []

      application_choices.each do |choice|
        if CandidateInterface::EndOfCyclePolicy.cancel_application_because_option_unavailable?(choice)
          ApplicationStateChange.new(choice).cancel!
          cancelled_choices << choice
        else
          SendApplicationToProvider.new(application_choice: choice).call
        end
      end

      if application_choices.any?(&:awaiting_provider_decision?)
        CandidateMailer.application_sent_to_provider(application_form).deliver_later
        cancelled_choices.each do |choice|
          CandidateMailer.eoc_choice_unavailable_and_still_waiting_on_other_choices(choice).deliver_later
        end
      else
        cancelled_choices.each do |choice|
          CandidateMailer.eoc_choice_unavailable_and_no_other_choices(choice).deliver_later
        end
      end
    end
  end
end

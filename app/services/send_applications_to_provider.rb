# This worker will be scheduled to run nightly
class SendApplicationsToProvider
  def call
    GetApplicationFormsReadyToSendToProviders.call.each do |application_form|
      application_form.application_choices.each do |choice|
        SendApplicationToProvider.new(application_choice: choice).call
        SendNewApplicationEmailToProvider.new(application_choice: choice).call
      end

      CandidateMailer.application_under_consideration(application_form).deliver_now
    end
  end
end

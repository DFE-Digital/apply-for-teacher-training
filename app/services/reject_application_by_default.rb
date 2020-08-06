class RejectApplicationByDefault
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    ActiveRecord::Base.transaction do
      application_choice.update(rejected_by_default: true, rejected_at: Time.zone.now)
      ApplicationStateChange.new(application_choice).reject_by_default!
      SetDeclineByDefault.new(application_form: application_choice.application_form).call
    end

    StateChangeNotifier.call(:reject_application_by_default, application_choice: application_choice)
    SendRejectByDefaultEmailToProvider.new(application_choice: application_choice).call

    # We delay sending the candidate email because we want processing for all
    # applications for a given candidate to finish before picking the email
    # template - they depend on the status of the candidate's other application
    # choices.
    SendCandidateRejectionEmailWorker.perform_in(1.minute, application_choice.id)
  end
end

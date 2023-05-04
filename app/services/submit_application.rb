class SubmitApplication
  attr_reader :application_choice

  def initialize(application_choice)
    @application_choice = application_choice
  end

  def call
    application_choice.application_form.update!(submitted_at: Time.zone.now)

    SendApplicationToProvider.call(application_choice)

    CandidateMailer.application_submitted(application_choice.application_form).deliver_later
  end
end

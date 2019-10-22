class SubmitApplication
  attr_reader :application_form

  def initialize(application_form)
    @application_form = application_form
    @application_choices = application_form.application_choices
    @candidate_email = application_form.candidate.email_address
  end

  def call
    ActiveRecord::Base.transaction do
      application_choices.each do |application_choice|
        ApplicationStateChange.new(application_choice).submit!
      end
    end

    application_form.update!(submitted_at: Time.now)

    application_form.update_attribute(:reference, new_application_reference)

    CandidateMailer
      .submit_application_email(to: candidate_email, application_ref: application_form.reference)
      .deliver_now
  end

private
  def new_application_reference
    reference_length = 6
    letters = ('A'..'Z').to_a
    digits = ('0'..'9').to_a

    (1..reference_length).map { (letters + digits).sample }.join
  end
end

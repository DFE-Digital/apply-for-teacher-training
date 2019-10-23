class SubmitApplication
  attr_reader :application_choices, :candidate_email

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

    @application_form.update!(submitted_at: Time.now)

    CandidateMailer.submit_application_email(to: candidate_email,
                                             application_ref: '1234567890').deliver_now
  end
end

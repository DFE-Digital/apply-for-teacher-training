# This worker will be as a one-off task to inform previously unsuccessful candidates about apply again
class SendApplyAgainCallToAction
  include Sidekiq::Worker

  def perform
    unsuccessful_application_forms.find_each do |application_form|
      CandidateMailer.apply_again_call_to_action(application_form).deliver
    end
  end

private

  def unsuccessful_application_forms
    ApplicationForm
      .joins(:application_choices)
      .joins("LEFT OUTER JOIN emails ON emails.application_form_id = application_forms.id AND emails.mailer = 'candidate_mailer' AND emails.mail_template = 'apply_again_call_to_action'")
      .joins('LEFT OUTER JOIN application_forms AS subsequent_application_form ON application_forms.id = subsequent_application_form.previous_application_form_id')
      .where.not(application_choices: {
        status: ApplicationStateChange.valid_states - ApplicationStateChange::UNSUCCESSFUL_END_STATES.map(&:to_sym),
      })
      .where(emails: { id: nil })
      .where(subsequent_application_form: { id: nil })
      .distinct
  end
end

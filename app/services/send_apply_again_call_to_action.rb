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
      .where
      .not(application_choices: {
        status: ApplicationStateChange.valid_states - ApplicationStateChange::UNSUCCESSFUL_END_STATES.map(&:to_sym),
      })
      .distinct
  end
end

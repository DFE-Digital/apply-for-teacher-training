class Adviser::RefreshAdviserStatusWorker
  include Sidekiq::Worker

  def perform(application_form_id)
    return unless FeatureFlag.active?(:adviser_sign_up)

    application_form = ApplicationForm.find(application_form_id)

    candidate_matchback = Adviser::CandidateMatchback.new(application_form)
    candidate_matchback_adviser_status = candidate_matchback.teacher_training_adviser_sign_up.adviser_status

    # The Application Form is in this state by default,
    # We may have only just sent the sign-up to the GIT API and manually updated the Application Form's adviser_status to 'waiting_to_be_assigned'
    # We don't want to go back a step
    return if candidate_matchback_adviser_status == 'unassigned'

    application_form.update!(adviser_status: candidate_matchback_adviser_status)
  end
end

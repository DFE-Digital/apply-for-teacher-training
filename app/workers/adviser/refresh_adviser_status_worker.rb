class Adviser::RefreshAdviserStatusWorker
  include Sidekiq::Worker

  def perform(application_form_id)
    return unless FeatureFlag.active?(:adviser_sign_up)

    application_form = ApplicationForm.find(application_form_id)

    adviser_status = candidate_matchback_adviser_status(application_form)

    # The Application Form is in this state by default,
    # We may have only just sent the sign-up to the GIT API and manually updated the Application Form's adviser_status to 'waiting_to_be_assigned'
    # We don't want to go back a step
    return if adviser_status == 'unassigned'

    application_form.update!(adviser_status:)
  end

private

  def candidate_matchback_adviser_status(application_form)
    candidate_matchback = Adviser::CandidateMatchback.new(application_form)
    candidate_matchback.teacher_training_adviser_sign_up.adviser_status
  rescue GetIntoTeachingApiClient::ApiError
    # This API often falls over - return `unassigned` we can try again later
    'unassigned'
  end
end

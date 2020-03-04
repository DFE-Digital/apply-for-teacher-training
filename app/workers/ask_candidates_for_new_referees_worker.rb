class AskCandidatesForNewRefereesWorker
  include Sidekiq::Worker

  def perform
    GetRefereesThatNeedReplacing.call.each do |reference|
      SendNewRefereeRequestEmail.call(
        application_form: reference.application_form,
        reference: reference,
        reason: :not_responded,
      )
    end
  end
end

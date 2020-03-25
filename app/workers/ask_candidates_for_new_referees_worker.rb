class AskCandidatesForNewRefereesWorker
  include Sidekiq::Worker

  def perform
    GetRefereesThatNeedReplacing.call.each do |reference|
      SendNewRefereeRequestEmail.call(
        reference: reference,
        reason: :not_responded,
      )
    end
  end
end

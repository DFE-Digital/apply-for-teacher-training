class DeleteAllDraftsWorker
  include Sidekiq::Worker

  sidekiq_options queue: :low_priority

  def perform
    Candidate::DeleteDraftWithdrawalReasonRecordsWorker.perform_async
    Provider::DeleteDraftPoolInvitesWorker.perform_async
    Candidate::DeleteDraftCandidatePreferencesWorker.perform_async
  end
end

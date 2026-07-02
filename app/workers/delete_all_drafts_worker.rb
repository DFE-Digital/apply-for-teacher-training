class DeleteAllDraftsWorker < ApplicationJob
  queue_as :low_priority

  def perform
    Candidate::DeleteDraftWithdrawalReasonRecordsWorker.perform_later
    Provider::DeleteDraftPoolInvitesWorker.perform_later
    Candidate::DeleteDraftCandidatePreferencesWorker.perform_later
  end
end

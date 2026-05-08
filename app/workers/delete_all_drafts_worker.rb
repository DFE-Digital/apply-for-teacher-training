class DeleteAllDraftsWorker < ApplicationJob
  self.queue_adapter = :solid_queue

  def perform
    Candidate::DeleteDraftWithdrawalReasonRecordsWorker.perform_later
    Provider::DeleteDraftPoolInvitesWorker.perform_later
    Candidate::DeleteDraftCandidatePreferencesWorker.perform_later
  end
end

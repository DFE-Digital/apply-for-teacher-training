class DeleteAllDraftsWorker < ApplicationJob
  self.queue_adapter = :solid_queue

  queue_as :low_priority

  def perform
    Candidate::DeleteDraftWithdrawalReasonRecordsWorker.perform_now
    Provider::DeleteDraftPoolInvitesWorker.perform_now
    Candidate::DeleteDraftCandidatePreferencesWorker.perform_now
  end
end

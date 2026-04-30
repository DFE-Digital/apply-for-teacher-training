class DeleteAllDraftsWorker < ApplicationJob
  # include Sidekiq::Worker

  # sidekiq_options queue: :low_priority
  self.queue_adapter = :solid_queue


  def perform
    Candidate::DeleteDraftWithdrawalReasonRecordsWorker.perform_later
    Provider::DeleteDraftPoolInvitesWorker.perform_later
    Candidate::DeleteDraftCandidatePreferencesWorker.perform_later
  end
end

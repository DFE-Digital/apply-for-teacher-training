class Candidate::DeleteDraftWithdrawalReasonRecordsWorker < ApplicationJob
  self.queue_adapter = :solid_queue

  queue_as :low_priority

  def perform
    WithdrawalReason.draft.where('updated_at < ?', 3.days.ago).delete_all
  end
end

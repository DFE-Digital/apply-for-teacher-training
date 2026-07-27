class Candidate::DeleteDraftWithdrawalReasonRecordsWorker < ApplicationJob
  queue_as :low_priority

  def perform
    WithdrawalReason.draft.where('updated_at < ?', 3.days.ago).delete_all
  end
end

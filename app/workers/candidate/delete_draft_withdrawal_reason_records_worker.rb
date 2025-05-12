class Candidate::DeleteDraftWithdrawalReasonRecordsWorker
  include Sidekiq::Worker

  sidekiq_options queue: :low_priority

  def perform
    WithdrawalReason.draft.where('updated_at < ?', 3.days.ago).delete_all
  end
end

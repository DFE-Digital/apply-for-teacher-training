class RemoveInactiveSupportUsersWorker < ApplicationJob
  self.queue_adapter = :solid_queue

  queue_as :low_priority

  def perform
    SupportUser.where('last_signed_in_at < ?', 9.months.ago)
    .or(SupportUser.where('last_signed_in_at IS NULL AND created_at < ?', 9.months.ago))
    &.discard_all
  end
end

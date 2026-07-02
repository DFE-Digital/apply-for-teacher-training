class DeleteExpiredSessionsWorker < ApplicationJob
  queue_as :low_priority

  def perform
    Session.where('updated_at < ?', 7.days.ago).delete_all
    DsiSession.where('updated_at < ?', 7.days.ago).delete_all
  end
end

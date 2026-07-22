class Provider::DeleteDraftPoolInvitesWorker < ApplicationJob
  self.queue_adapter = :solid_queue

  queue_as :low_priority

  def perform
    Pool::Invite.draft.where('updated_at < ?', 3.days.ago).delete_all
  end
end

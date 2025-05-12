class Provider::DeleteDraftPoolInvitesWorker
  include Sidekiq::Worker

  sidekiq_options queue: :low_priority

  def perform
    Pool::Invite.draft.where('updated_at < ?', 3.days.ago).delete_all
  end
end

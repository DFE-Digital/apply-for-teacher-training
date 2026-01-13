class RemoveInactiveSupportUsersWorker
  include Sidekiq::Worker

  sidekiq_options queue: :low_priority

  def perform
    SupportUser.where('last_signed_in_at < ?', 9.months.ago)&.discard_all
  end
end

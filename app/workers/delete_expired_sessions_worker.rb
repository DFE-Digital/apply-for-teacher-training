class DeleteExpiredSessionsWorker
  include Sidekiq::Worker

  sidekiq_options queue: :low_priority

  def perform
    Session.where('updated_at < ?', 7.days.ago).delete_all
  end
end

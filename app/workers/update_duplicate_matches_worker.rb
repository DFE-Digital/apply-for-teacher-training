class UpdateDuplicateMatchesWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0, queue: :low_priority

  def perform(notify_slack_at: nil)
    UpdateDuplicateMatches.new(notify_slack_at:).save!
  end
end

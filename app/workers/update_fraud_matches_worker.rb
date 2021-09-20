class UpdateFraudMatchesWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0, queue: :low_priority

  def perform
    matches = UpdateFraudMatches.new
    matches.save!
  end
end

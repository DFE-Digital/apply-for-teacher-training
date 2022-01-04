class UpdateFraudMatchesWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0, queue: :low_priority

  def perform
    if FeatureFlag.active?(:duplicate_matching)
      matches = UpdateDuplicateMatches.new
      matches.save!
    else
      matches = UpdateFraudMatches.new
      matches.save!
    end
  end
end

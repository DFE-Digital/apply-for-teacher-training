class UpdateFraudMatchesWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0, queue: :low_priority

  def perform
    matches =
      if FeatureFlag.active?(:duplicate_matching)
        UpdateDuplicateMatches.new
      else
        UpdateFraudMatches.new
      end
    matches.save!
  end
end

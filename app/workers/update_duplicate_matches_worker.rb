class UpdateDuplicateMatchesWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0, queue: :low_priority

  def perform
    UpdateDuplicateMatches.new.save!
  end
end

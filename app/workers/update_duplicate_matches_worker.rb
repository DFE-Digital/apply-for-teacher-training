class UpdateDuplicateMatchesWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0, queue: :low_priority

  def perform(options = {})
    UpdateDuplicateMatches.new(**options).save!
  end
end

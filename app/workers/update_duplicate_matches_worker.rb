class UpdateDuplicateMatchesWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0, queue: :low_priority

  def perform(options = {})
    options.symbolize_keys!
    UpdateDuplicateMatches.new(**options).save!
  end
end

class SyncAllFromFind
  include Sidekiq::Worker
  sidekiq_options retry: 3, queue: :low_priority

  def perform
    SyncAllProvidersFromFind.call
  end
end

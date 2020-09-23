class SyncAllFromFind
  include Sidekiq::Worker
  sidekiq_options retry: 3, queue: :low_priority

  def perform
    FindSync::SyncAllProvidersFromFind.call
  end
end

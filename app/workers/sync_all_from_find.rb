class SyncAllFromFind
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform
    SyncAllProvidersFromFind.call
  end
end

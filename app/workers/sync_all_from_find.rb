class SyncAllFromFind
  include Sidekiq::Worker

  def perform
    SyncAllProvidersFromFind.call
  end
end

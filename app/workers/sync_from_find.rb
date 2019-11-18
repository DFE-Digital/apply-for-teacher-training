class SyncFromFind
  include Sidekiq::Worker

  def perform
    Rails.configuration.providers_to_sync[:codes].each do |code|
      SyncProviderFromFind.call(provider_code: code)
    end
  end
end

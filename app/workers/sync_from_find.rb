class SyncFromFind
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform
    Rails.configuration.providers_to_sync[:codes].each do |code|
      SyncProviderFromFind.call(provider_code: code, sync_courses: true)
    end
  end
end

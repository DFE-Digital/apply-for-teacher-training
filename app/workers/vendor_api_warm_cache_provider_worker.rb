class VendorAPIWarmCacheProviderWorker
  include Sidekiq::Worker

  def perform(api_version, provider_id)
    WarmProviderCache.new.call(api_version, provider_id)
  end
end

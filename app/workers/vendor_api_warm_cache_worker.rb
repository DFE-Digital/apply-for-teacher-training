class VendorAPIWarmCacheWorker
  include Sidekiq::Worker

  def perform
    WarmCache.call
  end
end

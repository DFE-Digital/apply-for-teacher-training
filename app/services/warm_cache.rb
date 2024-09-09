class WarmCache
  def call
    # Get all provider who have an api token that has been used in the past month
    ProvidersForVendorAPICacheWarmingQuery.new.call.each do |provider|
      # Find the api version they last used
      api_version = ProviderLatestAPIVersionQuery.new(provider_id: provider.id).call

      # skip as we couldn't find any api requests
      next unless api_version

      # Run a background job for each provider to cache their applications
      Rails.logger.tagged('WarmCache').info "VendorAPIWarmCacheProviderWorker enqueued for provider id #{provider.id} with api version #{api_version}"
      ::VendorAPIWarmCacheProviderWorker.perform_async(api_version, provider.id)
    end
  end
end

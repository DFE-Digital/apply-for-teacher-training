class WarmCache
  def call
    # Get all provider who have an api token that has been used in the past month
    ProvidersForVendorAPICacheWarmingQuery.new.call.each do |provider|
      # Find the api version they last used
      api_version = VendorAPIRequest
        .where(provider_id: provider.id)
        .select("regexp_matches(request_path, '/api/v(.*)/applications') result")
        .order(created_at: :desc)
        .first&.result&.first

      # skip as we couldn't find any api requests
      next unless api_version

      # Run a background job for each provider to cache their applications
      Rails.logger.tagged('WarmCache').info "VendorAPIWarmCacheProviderWorker enqueued for provider id #{provider.id} with api version #{api_version}"
      ::VendorAPIWarmCacheProviderWorker.perform_async(api_version, provider.id)
    end
  end
end

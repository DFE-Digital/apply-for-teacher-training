class ProvidersForVendorAPICacheWarmingQuery
  def call(since: 1.month.ago)
    Provider
      .joins(:vendor_api_tokens)
      .where('vendor_api_tokens.last_used_at > ?', since)
      .distinct
  end
end

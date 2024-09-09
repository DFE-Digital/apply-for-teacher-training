class ProviderLatestAPIVersionQuery
  def initialize(provider_id:)
    @provider_id = provider_id
  end

  def call
    VendorAPIRequest
      .select("substring(request_path, '/api/v(.*)/applications') api_version")
      .where(provider_id: @provider_id)
      .order(api_version: :desc)
      .first&.api_version
  end
end

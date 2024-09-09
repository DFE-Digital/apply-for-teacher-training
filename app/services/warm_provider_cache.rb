class WarmProviderCache
  include VendorAPI::ApplicationDataConcerns

  attr_reader :version_number

  def call(api_version, provider_id)
    @provider = Provider.find(provider_id)
    @version_number = api_version
    # For each of the application choices generate a cache entry
    application_choices_visible_to_provider
      .where('application_choices.updated_at between (?) and (?)', Date.new(2024, 9, 2), Date.new(2024, 9, 5))
      .find_each do |application_choice|
      presenter = VendorAPI::ApplicationPresenter.new(api_version, application_choice)
      Rails.cache.write(
        presenter.send(:cache_key, application_choice, api_version),
        schema(presenter),
        expires_in: VendorAPI::ApplicationPresenter::CACHE_EXPIRES_IN,
      )

      Rails.logger.tagged('WarmProviderCache').info "ApplicationChoice cached: #{application_choice.id}"
    end
  end

  def schema(presenter)
    @schema ||= presenter.send(:schema)
  end

  def current_provider
    @provider
  end
end

class WarmProviderCache
  include VendorAPI::ApplicationDataConcerns

  attr_reader :version_number

  def call(api_version, provider_id)
    @provider = Provider.find(provider_id)
    @version_number = api_version
    r = {@provider.name => []}
    # For each of the application choices generate a cache entry
    application_choices_visible_to_provider
      .where('application_choices.updated_at between (?) and (?)', Date.new(2024, 9, 2), Date.new(2024, 9, 5))
      .where.not(application_choices: { status: ['unsubmitted'] })
      .find_each do |application_choice|
      presenter = VendorAPI::ApplicationPresenter.new(api_version, application_choice)
      presenter.as_json
      presenter.serialized_json
      Rails.logger.tagged('WarmProviderCache').info "ApplicationChoice cached: #{application_choice.id}"
      r[@provider.name] << application_choice.id
    end
    r
  end

  def current_provider
    @provider
  end
end

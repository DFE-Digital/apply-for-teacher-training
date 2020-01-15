class SyncAllProvidersFromFind
  def self.call
    # Request basic details for all providers
    #
    # For the full response, see:
    # https://api2.publish-teacher-training-courses.service.gov.uk/api/v3/recruitment_cycles/2020/providers
    find_providers = FindAPI::Provider.current_cycle.all

    sync_providers(find_providers)
  end

  def self.sync_providers(find_providers)
    find_providers.each do |find_provider|
      SyncProviderFromFind.call(
        provider_name: find_provider.provider_name,
        provider_code: find_provider.provider_code,
      )
    end
  end

  private_class_method :sync_providers
end

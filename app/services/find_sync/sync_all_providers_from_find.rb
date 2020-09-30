module FindSync
  class SyncAllProvidersFromFind
    def self.call
      # Request basic details for all providers
      #
      # For the full response, see:
      # https://api2.publish-teacher-training-courses.service.gov.uk/api/v3/recruitment_cycles/2020/providers
      sync_providers(
        FindAPI::Provider.recruitment_cycle(2020).all,
      )

      if FeatureFlag.active?(:start_syncing_2021_courses)
        sync_providers(
          FindAPI::Provider.recruitment_cycle(2021).all,
        )
      end

      FindSyncCheck.set_last_sync(Time.zone.now)
    rescue JsonApiClient::Errors::ApiError
      raise FindSync::SyncError
    end

    def self.sync_providers(find_providers)
      find_providers.each do |find_provider|
        SyncProviderFromFind.call(
          provider_name: find_provider.provider_name,
          provider_code: find_provider.provider_code,
          provider_recruitment_cycle_year: find_provider.recruitment_cycle_year,
        )
      end
    end

    private_class_method :sync_providers
  end
end

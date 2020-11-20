module TeacherTrainingAPI
  class SyncAllProvidersAndCourses
    def self.call
      sync_providers(
        TeacherTrainingAPI::Provider.where(year: 2021).all,
      )
    rescue JsonApiClient::Errors::ApiError
      raise TeacherTrainingAPI::SyncError
    end

    def self.sync_providers(providers_from_api)
      providers_from_api.each do |provider_from_api|
        TeacherTrainingAPI::SyncProvider.call(
          provider_name: provider_from_api.name,
          provider_code: provider_from_api.code,
          provider_recruitment_cycle_year: 2021,
        )
      end
    end

    private_class_method :sync_providers
  end
end

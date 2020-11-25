module TeacherTrainingAPI
  class SyncAllProvidersAndCourses
    def self.call
      begin
        (1..).each do |page|
          sync_providers(
            TeacherTrainingAPI::Provider.where(year: 2021).paginate(page: page, per_page: 500).all,
          )
        end
      rescue JsonApiClient::Errors::ClientError
        # This is how the API responds when we run out of pages :/
      end

      TeacherTrainingAPI::SyncCheck.set_last_sync(Time.zone.now)
    rescue JsonApiClient::Errors::ApiError
      raise TeacherTrainingAPI::SyncError
    end

    def self.sync_providers(providers_from_api)
      providers_from_api.each do |provider_from_api|
        TeacherTrainingAPI::SyncProvider.new(
          provider_from_api: provider_from_api,
          recruitment_cycle_year: 2021,
        ).call
      end
    end

    private_class_method :sync_providers
  end
end

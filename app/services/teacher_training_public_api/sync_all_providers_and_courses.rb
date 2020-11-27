module TeacherTrainingPublicAPI
  class SyncAllProvidersAndCourses
    def self.call
      begin
        (1..).each do |page|
          sync_providers(
            TeacherTrainingPublicAPI::Provider
              .where(year: RecruitmentCycle.current_year)
              .paginate(page: page, per_page: 500)
              .all,
          )
        end
      rescue JsonApiClient::Errors::ClientError
        # This is how the API responds when we run out of pages :/
      end

      TeacherTrainingPublicAPI::SyncCheck.set_last_sync(Time.zone.now)
    rescue JsonApiClient::Errors::ApiError
      raise TeacherTrainingPublicAPI::SyncError
    end

    def self.sync_providers(providers_from_api)
      providers_from_api.each do |provider_from_api|
        TeacherTrainingPublicAPI::SyncProvider.new(
          provider_from_api: provider_from_api,
          recruitment_cycle_year: RecruitmentCycle.current_year,
        ).call
      end
    end

    private_class_method :sync_providers
  end
end

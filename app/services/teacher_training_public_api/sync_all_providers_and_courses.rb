module TeacherTrainingPublicAPI
  class SyncAllProvidersAndCourses
    def self.call(recruitment_cycle_year: ::RecruitmentCycle.current_year, incremental_sync: true)
      is_last_page = false
      page_number = 0
      until is_last_page
        page_number += 1

        scope = TeacherTrainingPublicAPI::Provider
          .where(year: recruitment_cycle_year)
          .paginate(page: page_number, per_page: 500)
        scope = scope.where(updated_since: TeacherTrainingPublicAPI::SyncCheck.updated_since) if incremental_sync
        response = scope.all

        sync_providers(response, recruitment_cycle_year)

        is_last_page = true if response.links.links['next'].nil?
      end

      TeacherTrainingPublicAPI::SyncCheck.set_last_sync(Time.zone.now)
    rescue JsonApiClient::Errors::ApiError
      raise TeacherTrainingPublicAPI::SyncError
    end

    def self.sync_providers(providers_from_api, recruitment_cycle_year)
      providers_from_api.each do |provider_from_api|
        TeacherTrainingPublicAPI::SyncProvider.new(
          provider_from_api: provider_from_api,
          recruitment_cycle_year: recruitment_cycle_year,
        ).call
      end
    end

    private_class_method :sync_providers
  end
end

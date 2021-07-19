module TeacherTrainingPublicAPI
  class SyncAllProvidersAndCourses
    def self.call(recruitment_cycle_year: ::RecruitmentCycle.current_year, incremental_sync: true)
      is_last_page = false
      page_number = 0
      until is_last_page
        page_number += 1

        scope = TeacherTrainingPublicAPI::Provider
          .where(year: recruitment_cycle_year)
          .paginate(page: page_number, per_page: 200)
        scope = scope.where(updated_since: TeacherTrainingPublicAPI::SyncCheck.updated_since) if incremental_sync
        delay_by = calculate_offset(page_number + 1, incremental_sync)
        response = scope.all

        sync_providers(response, recruitment_cycle_year, delay_by, incremental_sync)

        is_last_page = true if response.links.links['next'].nil?
      end

      TeacherTrainingPublicAPI::SyncCheck.set_last_sync(Time.zone.now)
    rescue JsonApiClient::Errors::ApiError
      raise TeacherTrainingPublicAPI::SyncError
    end

    def self.sync_providers(providers_from_api, recruitment_cycle_year, delay_by, incremental_sync)
      providers_from_api.each do |provider_from_api|
        TeacherTrainingPublicAPI::SyncProvider.new(
          provider_from_api: provider_from_api,
          recruitment_cycle_year: recruitment_cycle_year,
          delay_by: delay_by,
          incremental_sync: incremental_sync,
        ).call
      end
    end

    def self.calculate_offset(index, incremental_sync)
      return if incremental_sync

      (index * 3).minutes
    end

    private_class_method :sync_providers, :calculate_offset
  end
end

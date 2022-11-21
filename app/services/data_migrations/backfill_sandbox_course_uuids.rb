module DataMigrations
  class BackfillSandboxCourseUuids
    TIMESTAMP = 20221117152407
    MANUAL_RUN = true
    RECRUITMENT_CYCLE_YEAR = 2023

    def change
      raise 'Sandbox only' unless HostingEnvironment.sandbox_mode?

      providers.find_each(batch_size: 100) do |provider|
        courses_for_provider(provider).each do |course_from_api|
          next unless (match = matching_course(provider, course_from_api))

          match.update(uuid: course_from_api.uuid) unless match.uuid == course_from_api.uuid
        end
      end
    end

    def providers
      Provider
        .joins(:courses)
        .where(courses: { recruitment_cycle_year: RECRUITMENT_CYCLE_YEAR })
        .distinct
    end

    def courses_for_provider(provider)
      TeacherTrainingPublicAPI::Course.where(
        year: RECRUITMENT_CYCLE_YEAR,
        provider_code: provider.code,
      ).paginate(per_page: 500).to_a
    rescue JsonApiClient::Errors::NotFound
      []
    end

  private

    def matching_course(provider, course_from_api)
      Course.find_by(
        provider: provider,
        code: course_from_api.code,
        recruitment_cycle_year: RECRUITMENT_CYCLE_YEAR,
      )
    end
  end
end

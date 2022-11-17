module DataMigrations
  class BackfillSandboxCourseUuids
    TIMESTAMP = 20221117152407
    MANUAL_RUN = true

    def change
      raise 'Sandbox only' unless HostingEnvironment.sandbox_mode?

      Provider
        .joins(:courses).where(courses: { recruitment_cycle_year: 2023 }).distinct
        .find_each(batch_size: 100) do |provider|
          TeacherTrainingPublicAPI::Course.where(
            year: 2023,
            provider_code: provider.code,
          ).paginate(per_page: 500).each do |course_from_api|
            next unless (match = matching_course(provider, course_from_api))

            match.update(uuid: course_from_api.uuid) unless match.uuid == course_from_api.uuid
          end
        end
    end

  private

    def matching_course(provider, course_from_api)
      Course.find_by(
        provider: provider,
        code: course_from_api.code,
        recruitment_cycle_year: 2023,
      )
    end
  end
end

module DataMigrations
  class RemoveCoursesNotOnPublish
    TIMESTAMP = 20240422140246
    MANUAL_RUN = true

    def initialize(limit: nil)
      @limit = limit
    end

    def change
      records.each do |course|
        course.course_options.map(&:destroy!)
        course.course_subjects.map(&:destroy!)
        course.destroy!
      end
    end

    def dry_run
      "Number of courses in Apply but not in Publish: #{records.count}"
    end

    def records
      Course.current_cycle.where(uuid: deleted_courses_uuids).select { |record| record.application_choices.none? }
    end

    def deleted_courses_uuids
      uuids = []

      providers.find_each do |provider|
        all_courses_from_apply = provider.courses.current_cycle.pluck(:uuid)

        begin
          all_courses_from_publish = TeacherTrainingPublicAPI::Course.where(
            year: current_year,
            provider_code: provider.code,
          ).paginate(per_page: 500)
        rescue StandardError
          next
        end

        deleted_courses = all_courses_from_apply - all_courses_from_publish.map(&:uuid)
        uuids << deleted_courses
      end

      uuids.compact.flatten
    end

    def providers(recruitment_cycle_year: current_year)
      scope = Provider
      .joins(:courses)
      .where(courses: { recruitment_cycle_year: })
      .distinct
      scope = scope.limit(@limit) if @limit.present?
      scope
    end

    def current_year
      @current_year ||= RecruitmentCycleTimetable.current_year
    end
  end
end

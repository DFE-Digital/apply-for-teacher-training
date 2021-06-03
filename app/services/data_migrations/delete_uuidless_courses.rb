module DataMigrations
  class DeleteUuidlessCourses
    TIMESTAMP = 20210601155313
    MANUAL_RUN = true

    def change
      courses_without_uuid = Course.where(uuid: nil)
      raise 'Cannot delete courses with outstanding applications' if courses_without_uuid.flat_map(&:application_choices).any?

      course_options_without_uuid = courses_without_uuid.flat_map(&:course_options)
      course_subjects_without_uuid = courses_without_uuid.flat_map(&:course_subjects)
      course_subjects_without_uuid.each(&:destroy)
      course_options_without_uuid.each(&:destroy)
      courses_without_uuid.each(&:destroy)
    end
  end
end

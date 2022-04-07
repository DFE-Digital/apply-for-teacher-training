module DataMigrations
  class BackfillOriginalCourseOption
    TIMESTAMP = 20220407082738
    MANUAL_RUN = false

    def change
      ApplicationChoice.where(original_course_option: nil).find_each(batch_size: 100) do |application|
        application.update_columns(original_course_option_id: application.course_option.id)
      end
    end
  end
end

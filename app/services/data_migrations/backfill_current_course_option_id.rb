module DataMigrations
  class BackfillCurrentCourseOptionId
    TIMESTAMP = 20210419154319
    MANUAL_RUN = false

    def change
      sql = <<~POPULATE_CURRENT_OPTION_ID_SQL.squish
        UPDATE application_choices
           SET current_course_option_id = COALESCE(offered_course_option_id, course_option_id)
      POPULATE_CURRENT_OPTION_ID_SQL

      ActiveRecord::Base.connection.execute(sql)

      raise 'setting current_course_option_id failed' if ApplicationChoice.where(current_course_option_id: nil).any?
    end
  end
end

module DataMigrations
  class BackfillCoureseStatus
    TIMESTAMP = 20260817104904
    MANUAL_RUN = false

    def change
      Course
        .application_status_open
        .course_status_closed
        .update_all(course_status: 'open')
    end
  end
end

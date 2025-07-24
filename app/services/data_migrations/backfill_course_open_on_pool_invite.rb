module DataMigrations
  class BackfillCourseOpenOnPoolInvite
    TIMESTAMP = 20250724092408
    MANUAL_RUN = false

    def change
      courses = Course.current_cycle.joins(:published_invites).distinct

      ActiveRecord::Base.transaction do
        courses.find_each do |course|
          course.published_invites.update_all(course_open: course.open?)
        end
      end
    end
  end
end

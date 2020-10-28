module FindSync
  class CourseStudyModes
    def initialize(course)
      @course = course
    end

    def derive
      both_modes = %w[full_time part_time]
      return both_modes if @course.full_time_or_part_time?

      from_existing_course_options = @course.course_options.pluck(:study_mode).uniq
      (from_existing_course_options + [@course.study_mode]).uniq
    end
  end
end

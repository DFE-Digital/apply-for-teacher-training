module FindSync
  class CourseStudyModes
    def initialize(course)
      @course = course
    end

    def derive
      both_modes = %w[full_time part_time]
      return both_modes if @course.both_study_modes_available?

      from_existing_course_options = @course.course_options.pluck(:study_mode).uniq
      (from_existing_course_options + [@course.study_mode]).uniq
    end
  end
end

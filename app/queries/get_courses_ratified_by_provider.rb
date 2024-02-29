class GetCoursesRatifiedByProvider
  def self.call(provider:, previous_cycle: false)
    courses_scope = provider.accredited_courses
    course_cycle_scope = previous_cycle ? courses_scope.previous_cycle : courses_scope.current_cycle
    course_cycle_scope.joins(:course_options).distinct.where.not(provider:)
  end
end

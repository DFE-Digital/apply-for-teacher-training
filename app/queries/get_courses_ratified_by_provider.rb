class GetCoursesRatifiedByProvider
  def self.call(provider:)
    provider.accredited_courses
            .current_cycle
            .open_on_apply
            .joins(:course_options)
            .distinct
            .where.not(provider: provider)
  end
end

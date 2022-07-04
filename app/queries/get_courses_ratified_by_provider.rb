class GetCoursesRatifiedByProvider
  def self.call(provider:, previous_cycle:)
    if previous_cycle
      provider.accredited_courses
      .previous_cycle
      .unique_ratified_courses(provider)
    else
      provider.accredited_courses
      .current_cycle
      .open_on_apply
      .unique_ratified_courses(provider)
    end
  end
end

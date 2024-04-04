class GetCoursesByProviderAndRegion
  RegionProviderCourses = Struct.new(:region_code, :provider_name, :courses)

  def self.call
    Course
      .current_cycle
      .includes(:provider)
      .order('providers.region_code', 'providers.name')
      .group_by { |course| [course.provider.region_code, course.provider.name] }
      .map { |region_provider, courses| RegionProviderCourses.new(region_provider[0], region_provider[1], courses) }
      .group_by(&:region_code)
  end
end

class SyncProvidersFromFind
  def self.call
    # TODO: We're launching the pilot with these 3 providers, but at some point
    # we'll want to expand to others and we will need a better mechanism to
    # manage these.
    providers = ['R55', '1N1', 'S31']

    providers.each do |provider_code|
      find_provider = FindAPI::Provider
        .current_cycle
        .includes(:sites, courses: [:sites])
        .find(provider_code)
        .first
      find_courses = find_provider.courses
      find_sites = find_provider.sites

      provider = Provider.find_or_create_by(code: provider_code)
      provider.name = find_provider.provider_name
      provider.save

      sites = find_sites.map do |find_site|
        site = provider.sites.find_or_create_by(code: find_site.location_name)
        site.name = find_site.location_name
        site.save
        site
      end

      find_courses.each do |find_course|
        course = provider.courses.find_or_create_by(code: find_course.course_code)
        course.name = find_course.name
        course.level = find_course.level
        course.start_date = Date.parse(find_course.start_date)
        course.save

        find_course.sites.each do |find_course_site|
          course_option = CourseOption.find_or_create_by(
            site_id: sites.find { |s| s.name == find_course_site.location_name }.id,
            course_id: course.id,
            vacancy_status: 'B', # TODO: Should this be reflected by `find_course.has_vacancies?`
          )
        end
      end
    end
  end
end

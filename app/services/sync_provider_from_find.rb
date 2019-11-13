class SyncProviderFromFind
  def self.call(provider_code:)
    # Request all providers, courses and sites.
    #
    # For the full response, see:
    # https://api2.publish-teacher-training-courses.service.gov.uk/api/v3/recruitment_cycles/2020/providers/1N1/?include=sites,courses.sites
    find_provider = FindAPI::Provider
      .current_cycle
      .includes(:sites, courses: [:sites])
      .find(provider_code)
      .first

    provider = create_provider(find_provider)

    find_provider.courses.each do |find_course|
      create_course(find_course, provider)
    end
  end

  def self.create_provider(find_provider)
    provider = Provider.find_or_create_by(code: find_provider.provider_code)
    provider.name = find_provider.provider_name
    provider.save

    provider
  end

  def self.create_course(find_course, provider)
    course = provider.courses.find_or_create_by(code: find_course.course_code)
    course.name = find_course.name
    course.level = find_course.level
    course.start_date = Date.parse(find_course.start_date)
    course.exposed_in_find = find_course.findable?
    course.save

    find_course.sites.each do |find_site|
      site = provider.sites.find_or_create_by(code: find_site.code)
      site.name = find_site.location_name
      site.save

      CourseOption.find_or_create_by(
        site: site,
        course_id: course.id,
        vacancy_status: 'B', # TODO: Should this be reflected by `find_course.has_vacancies?`
      )
    end

    course
  end

  private_class_method :create_provider, :create_course
end

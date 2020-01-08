class SyncProviderFromFind
  def self.call(provider_name:, provider_code:)
    provider = create_or_update_provider(provider_name, provider_code)

    return unless provider.sync_courses?

    # Request provider, all courses and sites.
    #
    # For the full response, see:
    # https://api2.publish-teacher-training-courses.service.gov.uk/api/v3/recruitment_cycles/2020/providers/1N1/?include=sites,courses.sites
    find_provider = FindAPI::Provider
      .current_cycle
      .includes(:sites, courses: [:sites])
      .find(provider_code)
      .first

    find_provider.courses.each do |find_course|
      create_or_update_course(find_course, provider)
    end
  end

  def self.create_or_update_provider(provider_name, provider_code)
    provider = Provider.find_or_create_by(code: provider_code)
    provider.name = provider_name
    provider.save!

    provider
  end

  def self.create_or_update_course(find_course, provider)
    course = provider.courses.find_or_create_by(code: find_course.course_code)
    course.name = find_course.name
    course.level = find_course.level
    course.study_mode = find_course.study_mode
    course.recruitment_cycle_year = find_course.recruitment_cycle_year
    course.exposed_in_find = find_course.findable?
    if find_course[:accrediting_provider].present?
      accrediting_provider = Provider.find_or_create_by(code: find_course[:accrediting_provider][:provider_code]) do |accredit_provider|
        accredit_provider.name = find_course[:accrediting_provider][:provider_name]
        accredit_provider.save
      end
      course.accrediting_provider = accrediting_provider
    end
    course.save!

    find_course.sites.each do |find_site|
      site = provider.sites.find_or_create_by(code: find_site.code)

      site.name = find_site.location_name
      site.address_line1 = find_site.address1.strip
      site.address_line2 = find_site.address2.strip
      site.address_line3 = find_site.address3.strip
      site.address_line4 = find_site.address4.strip
      site.postcode = find_site.postcode.strip
      site.save!

      study_modes = \
        if course.study_mode == 'full_time_or_part_time'
          %i[full_time part_time]
        else
          [course.study_mode]
        end

      study_modes.each do |mode|
        CourseOption.find_or_create_by(
          site: site,
          course_id: course.id,
          study_mode: mode,
          vacancy_status: 'B', #TODO: Should this be reflected by `find_course.has_vacancies?`
        )
      end
    end

    course
  end

  private_class_method :create_or_update_provider, :create_or_update_course
end

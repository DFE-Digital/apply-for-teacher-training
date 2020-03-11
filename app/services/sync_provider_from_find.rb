class SyncProviderFromFind
  def self.call(provider_code:, provider_name: nil, sync_courses: false)
    provider = create_or_update_provider(provider_name, provider_code, sync_courses)

    return unless provider.sync_courses?

    # Request provider, all courses and sites.
    #
    # For the full response, see:
    # https://api2.publish-teacher-training-courses.service.gov.uk/api/v3/recruitment_cycles/2020/providers/1N1/?include=sites,courses.sites
    find_provider = FindAPI::Provider
      .current_cycle
      .includes(:sites, courses: [:sites, site_statuses: [:site]])
      .find(provider_code)
      .first

    update_provider(provider, find_provider)

    find_provider.courses.each do |find_course|
      create_or_update_course(find_course, provider)
    end
  end

  def self.create_or_update_provider(provider_name, provider_code, sync_courses)
    provider = Provider.find_or_create_by(code: provider_code)
    if sync_courses
      provider.sync_courses = sync_courses
      provider.save!
    end
    update_provider_name(provider, provider_name) if provider_name.present?

    provider
  end

  def self.update_provider_name(provider, provider_name)
    provider.name = provider_name
    provider.save!
  end

  def self.update_provider(provider, find_provider)
    provider.region_code = find_provider.region_code.strip if find_provider.region_code
    provider.name = find_provider.provider_name if find_provider.provider_name
    provider.save!
  end

  def self.create_or_update_course(find_course, provider)
    course = provider.courses.find_or_create_by(code: find_course.course_code)
    course.name = find_course.name
    course.level = find_course.level
    course.study_mode = find_course.study_mode
    course.qualification = find_course.qualification
    course.financial_support = find_course.financial_support
    course.start_date = find_course.start_date
    course.apply_from_date = find_course.applications_open_from
    course.course_length = find_course.course_length
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

    site_statuses = find_course.site_statuses

    find_course.sites.each do |find_site|
      site = provider.sites.find_or_create_by(code: find_site.code)

      site.name = find_site.location_name
      site.address_line1 = find_site.address1&.strip
      site.address_line2 = find_site.address2&.strip
      site.address_line3 = find_site.address3&.strip
      site.address_line4 = find_site.address4&.strip
      site.postcode = find_site.postcode&.strip
      site.save!

      find_site_status = site_statuses.find { |ss| ss.site.id == find_site.id }

      study_modes = \
        if course.both_study_modes_available?
          %i[full_time part_time]
        else
          [course.study_mode]
        end

      study_modes.each do |mode|
        course_option = CourseOption.find_or_create_by(
          site: site,
          course_id: course.id,
          study_mode: mode,
        )

        vacancy_status = derive_vacancy_status(
          status_description: find_site_status.vac_status,
          study_mode: course_option.study_mode,
        )
        course_option.update(vacancy_status: vacancy_status)
      end
    end

    course
  end

  def self.derive_vacancy_status(status_description:, study_mode:)
    case status_description
    when 'no_vacancies'
      :no_vacancies
    when 'both_full_time_and_part_time_vacancies'
      :vacancies
    when 'full_time_vacancies'
      study_mode == 'full_time' ? :vacancies : :no_vacancies
    when 'part_time_vacancies'
      study_mode == 'part_time' ? :vacancies : :no_vacancies
    else
      raise InvalidFindVacancyStatusError, status_description
    end
  end

  class InvalidFindVacancyStatusError < StandardError; end

  private_class_method :create_or_update_provider, :create_or_update_course
end

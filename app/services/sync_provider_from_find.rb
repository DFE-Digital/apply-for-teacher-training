class SyncProviderFromFind
  def self.call(provider_code:, provider_name: nil, sync_courses: false)
    new(provider_code, provider_name, sync_courses).call
  end

  attr_reader :provider_code, :provider_name, :sync_courses
  attr_accessor :provider

  def initialize(provider_code, provider_name, sync_courses)
    @provider_code = provider_code
    @provider_name = provider_name
    @sync_courses = sync_courses
  end

  def call
    @provider = create_or_update_provider

    return unless @provider.sync_courses?

    find_provider = fetch_provider_from_find_api
    update_provider_details_with_api_response(find_provider)
    find_provider.courses.each do |find_course|
      create_or_update_course(find_course)
    end
  end

private

  def create_or_update_provider
    Provider.find_or_create_by(code: provider_code).tap do |provider_record|
      provider_record.sync_courses = sync_courses if sync_courses
      provider_record.name = provider_name if provider_name.present?
      provider_record.save!
    end
  end

  def fetch_provider_from_find_api
    # Request provider, all courses and sites.
    #
    # For the full response, see:
    # https://api2.publish-teacher-training-courses.service.gov.uk/api/v3/recruitment_cycles/2020/providers/1N1/?include=sites,courses.sites
    FindAPI::Provider
      .current_cycle
      .includes(:sites, courses: [:sites, site_statuses: [:site]])
      .find(provider_code)
      .first
  end

  def update_provider_details_with_api_response(find_provider)
    provider.region_code = find_provider.region_code.strip if find_provider.region_code
    provider.name = find_provider.provider_name if find_provider.provider_name
    provider.save!
  end

  def create_or_update_course(find_course)
    course = provider.courses.find_or_create_by(code: find_course.course_code)
    assign_course_attributes_from_find(course, find_course)
    add_accrediting_provider(course, find_course[:accrediting_provider])

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

        vacancy_status = CourseVacancyStatus.new(
          find_site_status.vac_status,
          course_option.study_mode,
        ).derive
        course_option.update(vacancy_status: vacancy_status)
      end
    end

  end

  def assign_course_attributes_from_find(course, find_course)
    course.name = find_course.name
    course.level = find_course.level
    course.study_mode = find_course.study_mode
    course.description = find_course.description
    course.start_date = find_course.start_date
    course.course_length = find_course.course_length
    course.recruitment_cycle_year = find_course.recruitment_cycle_year
    course.exposed_in_find = find_course.findable?
  end

  def add_accrediting_provider(course, find_accrediting_provider)
    if find_accrediting_provider.present?
      accrediting_provider = Provider.find_or_initialize_by(code: find_accrediting_provider[:provider_code])
      accrediting_provider.name = find_accrediting_provider[:provider_name]
      accrediting_provider.save!

      course.accrediting_provider = accrediting_provider
    end
  end

  class CourseVacancyStatus
    def initialize(find_status_description, study_mode)
      @find_status_description = find_status_description
      @study_mode = study_mode
    end

    def derive
      case @find_status_description
      when 'no_vacancies'
        :no_vacancies
      when 'both_full_time_and_part_time_vacancies'
        :vacancies
      when 'full_time_vacancies'
        @study_mode == 'full_time' ? :vacancies : :no_vacancies
      when 'part_time_vacancies'
        @study_mode == 'part_time' ? :vacancies : :no_vacancies
      else
        raise InvalidFindStatusDescriptionError, @find_status_description
      end
    end

    class InvalidFindStatusDescriptionError < StandardError; end
  end
end

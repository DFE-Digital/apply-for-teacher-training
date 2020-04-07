class SyncProviderFromFind
  def self.call(provider_code:, provider_name: nil, sync_courses: false)
    new(provider_code, provider_name, sync_courses).call
  end

  attr_reader :provider_code, :provider_name
  attr_accessor :provider

  def initialize(provider_code, provider_name, sync_courses)
    @provider_code = provider_code
    @provider_name = provider_name
    @sync_courses = sync_courses
  end

  def call
    if sync_courses?
      find_provider = fetch_provider_from_find_api

      @provider = create_or_update_provider(
        base_provider_attrs.merge(
          provider_attrs_from(find_provider),
        ),
      )

      find_provider.courses.each do |find_course|
        create_or_update_course(find_course)
      end
    else
      @provider = create_or_update_provider(base_provider_attrs)
    end
  end

private

  def sync_courses?
    @sync_courses || existing_provider&.sync_courses
  end

  def base_provider_attrs
    {
      sync_courses: sync_courses? || false,
      name: provider_name,
    }
  end

  def provider_attrs_from(find_provider)
    {
      region_code: find_provider.region_code&.strip,
      name: find_provider.provider_name,
    }
  end

  def existing_provider
    Provider.find_by(code: provider_code)
  end

  def create_or_update_provider(attrs)
    # Prefer this to find_or_create_by as it results in 3x fewer audits
    if existing_provider
      existing_provider.update!(attrs)
    else
      new_provider = Provider.new(attrs.merge(code: provider_code)).save!
    end

    existing_provider || new_provider
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

  def create_or_update_course(find_course)
    course = provider.courses.find_or_create_by(code: find_course.course_code)
    assign_course_attributes_from_find(course, find_course)
    add_accredited_provider(course, find_course[:accrediting_provider])

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

      study_modes = CourseStudyModes.new(course).derive

      study_modes.each do |mode|
        course_option = CourseOption.find_or_initialize_by(
          site: site,
          course_id: course.id,
          study_mode: mode,
        )

        vacancy_status = CourseVacancyStatus.new(
          find_site_status.vac_status,
          course_option.study_mode,
        ).derive

        course_option.update!(vacancy_status: vacancy_status)
      end
    end

    handle_course_options_with_invalid_sites(course, find_course)
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

  def add_accredited_provider(course, find_accredited_provider)
    if find_accredited_provider.present?
      accredited_provider = Provider.find_or_initialize_by(code: find_accredited_provider[:provider_code])
      accredited_provider.name = find_accredited_provider[:provider_name]
      accredited_provider.save!

      course.accredited_provider = accredited_provider
    end
  end

  def handle_course_options_with_invalid_sites(course, find_course)
    course_options = course.course_options.joins(:site)
    canonical_site_codes = find_course.sites.map(&:code)
    invalid_course_options = course_options.where.not(sites: { code: canonical_site_codes })
    return if invalid_course_options.blank?

    chosen_course_option_ids = ApplicationChoice.where(course_option: invalid_course_options).pluck(:course_option_id)

    not_part_of_an_application = invalid_course_options.where.not(id: chosen_course_option_ids)
    not_part_of_an_application.delete_all
    part_of_an_application = invalid_course_options.where(id: chosen_course_option_ids)
    return if part_of_an_application.size.zero?

    part_of_an_application.update_all(invalidated_by_find: true)
    Raven.capture_message(
      "#{part_of_an_application.count} invalid course options chosen by candidates.",
    )
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

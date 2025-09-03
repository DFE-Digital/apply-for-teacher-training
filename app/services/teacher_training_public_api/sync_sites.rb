module TeacherTrainingPublicAPI
  # Create new Sites and CourseOptions for a course based on the values returned from the TTAPI
  #
  # If the course is closed for applications, set CourseOptions#vacancy_status to :no_vacancies
  #
  # If CourseOptions exist for a study mode that doesn't match the course study mode
  #  - mark them site_still_valid: false and vacancy_status: no_vacancies if they have applications
  #  - delete the CourseOption if no applications exist for the CourseOption
  #
  # There is no specification for what to do with orphaned sites that are not associated with a CourseOption
  #
  class SyncSites
    attr_reader :provider, :course

    include Sidekiq::Worker

    sidekiq_options retry: 3, queue: :low_priority

    def perform(provider_id, recruitment_cycle_year, course_id, course_status_from_api, incremental_sync = true)
      @provider = ::Provider.find(provider_id)
      @course = ::Course.includes(course_options: :site).find_by(id: course_id)
      @course_status_from_api = course_status_from_api
      @incremental_sync = incremental_sync

      api_sites = TeacherTrainingPublicAPI::Location.where(
        year: recruitment_cycle_year,
        provider_code: @provider.code,
        course_code: @course.code,
      ).paginate(per_page: 500)

      # 1. Create / Update Sites, Course Options and StudyMode combinations from the API
      api_sites_and_study_modes = api_sites.product(course.study_modes)

      api_sites_and_study_modes.each do |api_site, study_mode|
        site = create_or_update_site(api_site)
        create_or_update_course_option(site, study_mode) if site.present?
      end

      # 2. Disable or delete CourseOptions that exist in Apply but are not
      #    returned in API and do not match the study mode of the course
      disable_or_delete_obsolete_course_options(course, api_sites.map(&:uuid))
    rescue JsonApiClient::Errors::ApiError
      raise TeacherTrainingPublicAPI::SyncError
    end

  private

    def create_or_update_site(api_site)
      site = AssignSiteAttributes.new(api_site, provider).call

      site&.save!
      site
    rescue StandardError => e
      message = "SyncSites error, provider_id =  #{provider.id}, api_site_uuid = #{api_site.uuid} api_site_name = #{api_site.name}"
      Sentry.capture_exception(e, message:)
      nil
    end

    def create_or_update_course_option(site, study_mode)
      course_option = CourseOption.find_or_initialize_by(
        course_id: course.id,
        site:,
        study_mode:,
      )

      course_option.update!({
        site_still_valid: true,
        vacancy_status: vacancies_for(course, study_mode),
      })
    end

    def disable_or_delete_obsolete_course_options(course, api_site_uuids)
      course_options_for_deletion = course.reload.course_options.select do |course_option|
        !course_option.study_mode.in?(course.study_modes) || !course_option.site.uuid.in?(api_site_uuids)
      end

      course_options_for_deletion.each do |course_option|
        if course_option.application_choices.any? || course_option.current_application_choices.any?
          course_option.update(site_still_valid: false, vacancy_status: :no_vacancies)
        else
          course_option.destroy
        end
      end
    end

    def vacancies_for(course, study_mode)
      return :no_vacancies if @course_status_from_api == 'closed'

      if course.study_modes.include?(study_mode)
        :vacancies
      else
        :no_vacancies
      end
    end
  end
end

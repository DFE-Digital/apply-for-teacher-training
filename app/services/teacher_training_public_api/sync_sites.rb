module TeacherTrainingPublicAPI
  class SyncSites
    include FullSyncErrorHandler

    attr_reader :provider, :course

    include Sidekiq::Worker
    sidekiq_options retry: 3, queue: :low_priority

    def perform(provider_id, recruitment_cycle_year, course_id, incremental_sync = true, suppress_sync_update_errors = false)
      @provider = ::Provider.find(provider_id)
      @course = ::Course.find(course_id)
      @incremental_sync = incremental_sync
      @updates = {}
      @changeset = {}

      sites = TeacherTrainingPublicAPI::Location.where(
        year: recruitment_cycle_year,
        provider_code: @provider.code,
        course_code: @course.code,
      ).includes(:location_status).paginate(per_page: 500)

      sites.each { |site_from_api| sync_site(site_from_api) }

      handle_course_options_with_invalid_sites(sites)
      handle_course_options_with_reinstated_sites(sites)

      raise_update_error(@updates, @changeset) unless suppress_sync_update_errors
    rescue JsonApiClient::Errors::ApiError
      raise TeacherTrainingPublicAPI::SyncError
    end

  private

    def sync_site(site_from_api)
      site = AssignSiteAttributes.new(site_from_api, provider).call

      temp_site = AssignTempSiteAttributes.new(site_from_api, provider).call

      if site.changed? && !@incremental_sync
        @updates.merge!(site: true)
        @changeset.merge!(site.id => site.changes)
      end

      site.save!
      temp_site.save!

      create_course_options_for_site(site, site_from_api.location_status)
      # create_course_options_for_site(temp_site, site_from_api.location_status)
    end

    def create_course_options_for_site(site, site_status)
      study_modes(course).each do |study_mode|
        create_course_options(site, study_mode, site_status)
      end
    end

    def study_modes(course)
      both_modes = %w[full_time part_time]
      return both_modes if course.full_time_or_part_time?

      from_existing_course_options = course.course_options.pluck(:study_mode).uniq
      (from_existing_course_options + [course.study_mode]).uniq
    end

    def create_course_options(site, study_mode, site_status)
      course_option = CourseOption.find_or_initialize_by(
        site: site,
        course_id: course.id,
        study_mode: study_mode,
      )

      vacancy_status = vacancy_status(site_status.vacancy_status, study_mode)

      if course_option.vacancy_status != vacancy_status.to_s
        course_option.update!(vacancy_status: vacancy_status)

        @updates.merge!(course_option: true) if !@incremental_sync
      end
    end

    def vacancy_status(vacancy_status_from_api, study_mode)
      case vacancy_status_from_api
      when 'no_vacancies'
        :no_vacancies
      when 'both_full_time_and_part_time_vacancies'
        :vacancies
      when 'full_time_vacancies'
        study_mode == 'full_time' ? :vacancies : :no_vacancies
      when 'part_time_vacancies'
        study_mode == 'part_time' ? :vacancies : :no_vacancies
      else
        raise InvalidVacancyStatusDescriptionError, vacancy_status_from_api
      end
    end

    class InvalidVacancyStatusDescriptionError < StandardError; end

    def handle_course_options_with_invalid_sites(sites)
      course_options = @course.course_options.joins(:site)
      site_codes = sites.map(&:code)
      invalid_course_options = course_options.where.not(sites: { code: site_codes })
      return if invalid_course_options.blank?

      chosen_course_option_ids = ApplicationChoice
                                     .where(course_option: invalid_course_options)
                                     .or(ApplicationChoice.where(current_course_option: invalid_course_options))
                                     .pluck(:course_option_id, :current_course_option_id).flatten.uniq

      not_part_of_an_application = invalid_course_options.where.not(id: chosen_course_option_ids)
      not_part_of_an_application.delete_all
      part_of_an_application = invalid_course_options.where(id: chosen_course_option_ids)

      return if part_of_an_application.size.zero?

      part_of_an_application.each do |course_option|
        next if course_option.site_still_valid == false

        course_option.update!(site_still_valid: false)
      end
    end

    def handle_course_options_with_reinstated_sites(sites)
      withdrawn_course_options = @course.course_options.joins(:site).where(site_still_valid: false)
      site_codes = sites.map(&:code)

      course_options_to_reinstate = withdrawn_course_options.where(
        sites: { code: site_codes },
      )

      course_options_to_reinstate.each do |course_option|
        course_option.update!(site_still_valid: true)
      end
    end
  end
end

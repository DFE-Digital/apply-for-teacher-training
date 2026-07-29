module TeacherTrainingPublicAPI
  class SyncSiteAndCourseOptionWorker < ApplicationJob
    queue_as :high_priority

    retry_on StandardError, attempts: 3
    attr_reader :api_site, :api_study_mode, :course_study_modes, :course_id,
                :provider, :course_status_from_api

    def perform(publish_api_site, api_study_mode, course_study_modes, course_id, provider, course_status_from_api)
      @api_site = TeacherTrainingPublicAPI::Location.new(publish_api_site)
      @api_study_mode = api_study_mode
      @course_study_modes = course_study_modes
      @course_id = course_id
      @provider = provider
      @course_status_from_api = course_status_from_api

      site = create_or_update_site

      if site.present?
        create_or_update_course_option(site)
      end
    end

  private

    def create_or_update_site
      site = AssignSiteAttributes.new(api_site, provider).call

      site&.save!
      site
    rescue ArgumentError
      Sentry.capture_message("SyncSites error, provider_id =  #{provider.id}, api_site_uuid = #{api_site.uuid} api_site_name = #{api_site.name}")
      site
    end

    def create_or_update_course_option(site)
      course_option = CourseOption.find_or_initialize_by(
        course_id:,
        site:,
        study_mode: api_study_mode,
      )

      course_option.update!({
        site_still_valid: true,
        vacancy_status:,
      })
    end

    def vacancy_status
      return :no_vacancies if course_status_from_api == 'closed'

      if course_study_modes.include?(api_study_mode)
        :vacancies
      else
        :no_vacancies
      end
    end
  end
end

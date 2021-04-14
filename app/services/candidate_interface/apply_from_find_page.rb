module CandidateInterface
  class ApplyFromFindPage
    def initialize(provider_code:, course_code:, current_candidate: nil)
      @provider_code = provider_code
      @course_code = course_code
      @current_candidate = current_candidate
    end

    def candidate_has_application_in_wrong_cycle?
      return false if course.blank? || @current_candidate.blank?

      @current_candidate.current_application.recruitment_cycle_year != RecruitmentCycle.current_year
    end

    def course_available_on_apply_and_candidate_signed_in?
      course_available_on_apply? && @current_candidate.present?
    end

    def course_available_on_apply_and_candidate_not_signed_in?
      course_available_on_apply? && @current_candidate.blank?
    end

    def course_available_on_apply_and_provider_not_on_ucas?
      course_available_on_apply? && provider_not_accepting_applications_via_ucas?
    end

    def course_available_on_apply?
      course_in_apply_database? && \
        course.open_on_apply? && \
        FeatureFlag.active?('pilot_open')
    end

    def ucas_only?
      course.present? && !course_available_on_apply?
    end

    def provider_not_accepting_applications_via_ucas?
      provider&.not_accepting_appplications_on_ucas?
    end

    def course
      @_course ||= load_course
    end

  private

    def course_in_apply_database?
      course.present? && course.is_a?(Course)
    end

    def load_course
      if !provider
        fetch_course_from_api
      else
        provider.courses.current_cycle.where(exposed_in_find: true).find_by!(code: @course_code)
      end
    rescue ActiveRecord::RecordNotFound
      fetch_course_from_api
    end

    def provider
      @_provider ||= Provider.find_by(code: @provider_code)
    end

    def fetch_course_from_api
      Rails.cache.fetch ['course-public-api-request', @provider_code, @course_code], expires_in: 5.minutes do
        course = TeacherTrainingPublicAPI::Course.fetch(@provider_code, @course_code)
        course&.sites # cache subsequent calls to #sites too (this method is memoized)
        course
      end
    end
  end
end

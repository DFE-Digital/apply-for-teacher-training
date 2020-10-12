module CandidateInterface
  class ApplyFromFindPage
    attr_accessor :course

    def initialize(provider_code:, course_code:)
      @provider_code = provider_code
      @course_code = course_code
      @can_apply_on_apply = false
      @course_on_find = false
      @course = nil
    end

    def determine_whether_course_is_on_find_or_apply
      provider = Provider.find_by!(code: @provider_code)
      @course = provider.courses.where(exposed_in_find: true).find_by!(code: @course_code)

      if @course&.open_on_apply? && pilot_open?
        @can_apply_on_apply = true
        @course_on_find = true
      elsif @course.present?
        @course_on_find = true
      end
    rescue ActiveRecord::RecordNotFound
      @course = fetch_course_from_api
      @course_on_find = true if @course.present?
    end

    def can_apply_on_apply?
      @can_apply_on_apply
    end

    def course_on_find?
      @course_on_find
    end

  private

    def pilot_open?
      FeatureFlag.active?('pilot_open')
    end

    def fetch_course_from_api
      Rails.cache.fetch ['course-api-request', @provider_code, @course_code], expires_in: 5.minutes do
        FindAPI::Course.fetch(@provider_code, @course_code)
      end
    end
  end
end

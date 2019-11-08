module CandidateInterface
  # The Apply from Find page is the landing page for candidates coming from the
  # Find postgraduate teacher training (https://find-postgraduate-teacher-training.education.gov.uk/)
  class ApplyFromFindController < CandidateInterfaceController
    skip_before_action :authenticate_candidate!
    skip_before_action :require_basic_auth_for_ui, if: -> { ENV['DISABLE_BASIC_AUTH_FOR_LANDING_PAGE'] }

    rescue_from ActionController::ParameterMissing, with: :render_not_found

    def show
      provider_code = params.fetch(:providerCode)
      course_code = params.fetch(:courseCode)

      course = FindAPI::Course.fetch(provider_code, course_code)

      if course.nil?
        render_not_found
      else
        @course = CoursePresenter.new course
      end
    end

  private

    def render_not_found
      render :not_found, status: :not_found
    end
  end
end

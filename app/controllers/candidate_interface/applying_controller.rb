module CandidateInterface
  class ApplyingController < CandidateInterfaceController
    skip_before_action :authenticate_candidate!

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

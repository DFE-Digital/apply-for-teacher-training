module CandidateInterface
  class ApplyController < CandidateInterfaceController
    rescue_from ActionController::ParameterMissing, with: :render_not_found

    def show
      provider_code = params.fetch(:providerCode)
      course_code = params.fetch(:courseCode)

      @course = FindAPI::Course.fetch(provider_code, course_code)

      render_not_found if @course.nil?
    end

  private

    def render_not_found
      render :not_found, status: :not_found
    end
  end
end

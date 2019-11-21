module CandidateInterface
  # The Apply from Find page is the landing page for candidates coming from the
  # Find postgraduate teacher training (https://find-postgraduate-teacher-training.education.gov.uk/)
  class ApplyFromFindController < CandidateInterfaceController
    skip_before_action :authenticate_candidate!
    skip_before_action :require_basic_auth_for_ui, if: -> { ENV['DISABLE_BASIC_AUTH_FOR_LANDING_PAGE'] }

    rescue_from ActionController::ParameterMissing, with: :render_not_found
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

    def show
      provider = Provider.find_by!(code: params.fetch(:providerCode))
      course = provider.courses.where(exposed_in_find: true).find_by!(code: params.fetch(:courseCode))
      @course = CoursePresenter.new(course)
    end

  private

    def render_not_found
      render :not_found, status: :not_found
    end
  end
end

module CandidateInterface
  # The Apply from Find page is the landing page for candidates coming from the
  # Find teacher training courses (https://find-teacher-training-courses.service.gov.uk/)
  class ApplyFromFindController < CandidateInterfaceController
    skip_before_action :authenticate_candidate!

    rescue_from ActionController::ParameterMissing, with: :render_not_found

    def show
      apply_from_find = ApplyFromFindPage.new(
        provider_code: params.fetch(:providerCode),
        course_code: params.fetch(:courseCode),
        current_candidate:,
      )

      @course = apply_from_find.course

      if apply_from_find.candidate_has_application_in_wrong_cycle?
        redirect_to candidate_interface_details_path
      elsif apply_from_find.course_in_apply_database_and_candidate_signed_in?
        current_candidate.update!(course_from_find_id: @course.id)
        redirect_to candidate_interface_interstitial_path
      elsif apply_from_find.course_in_apply_database_and_candidate_not_signed_in?
        redirect_to candidate_interface_create_account_or_sign_in_path(
          providerCode: params[:providerCode],
          courseCode: params[:courseCode],
        )
      else
        render_not_found
      end
    end

  private

    def render_not_found
      render :not_found, status: :not_found
    end
  end
end

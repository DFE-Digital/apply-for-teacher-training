module CandidateInterface
  # The Apply from Find page is the landing page for candidates coming from the
  # Find postgraduate teacher training (https://www.find-postgraduate-teacher-training.service.gov.uk/)
  class ApplyFromFindController < CandidateInterfaceController
    skip_before_action :authenticate_candidate!

    rescue_from ActionController::ParameterMissing, with: :render_not_found

    def show
      apply_from_find = ApplyFromFindPage.new(
        provider_code: params[:providerCode],
        course_code: params[:courseCode],
        current_candidate: current_candidate,
      )

      @course = apply_from_find.course

      if apply_from_find.candidate_has_application_in_wrong_cycle?
        redirect_to candidate_interface_application_form_path
      elsif apply_from_find.course_available_on_apply?
        if current_candidate
          current_candidate.update!(course_from_find_id: @course.id)

          redirect_to candidate_interface_interstitial_path
        elsif apply_from_find.provider_not_accepting_applications_via_ucas?
          redirect_to candidate_interface_create_account_or_sign_in_path(
            providerCode: params[:providerCode],
            courseCode: params[:courseCode],
          )
        else
          @choice = CandidateInterface::ApplyOnUCASOrApplyForm.new(
            provider_code: params[:providerCode], course_code: params[:courseCode],
          )

          render :apply_on_ucas_or_apply
        end
      elsif apply_from_find.ucas_only?
        render :apply_on_ucas_only
      else
        render_not_found
      end
    end

    def choose_service
      @choice = CandidateInterface::ApplyOnUCASOrApplyForm.new(apply_on_ucas_or_apply_params)

      if @choice.valid?
        if @choice.apply?
          redirect_to candidate_interface_create_account_or_sign_in_path(
            providerCode: @choice.provider_code,
            courseCode: @choice.course_code,
          )
        else
          redirect_to candidate_interface_apply_with_ucas_interstitial_path(
            provider_code: @choice.provider_code,
            course_code: @choice.course_code,
          )
        end
      else
        @course = ApplyFromFindPage.new(
          provider_code: apply_on_ucas_or_apply_params[:provider_code],
          course_code: apply_on_ucas_or_apply_params[:course_code],
          current_candidate: current_candidate,
        ).course

        render :apply_on_ucas_or_apply
      end
    end

    def ucas_interstitial
      @course = ApplyFromFindPage.new(
        provider_code: ucas_interstitial_params[:provider_code],
        course_code: ucas_interstitial_params[:course_code],
        current_candidate: current_candidate,
      ).course
    end

    private

    def render_not_found
      render :not_found, status: :not_found
    end

    def ucas_interstitial_params
      params.permit(:provider_code, :course_code)
    end

    def apply_on_ucas_or_apply_params
      params.require(:candidate_interface_apply_on_ucas_or_apply_form)
        .permit(:service, :provider_code, :course_code)
    end
  end
end

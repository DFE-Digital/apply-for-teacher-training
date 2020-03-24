module CandidateInterface
  # The Apply from Find page is the landing page for candidates coming from the
  # Find postgraduate teacher training (https://find-postgraduate-teacher-training.education.gov.uk/)
  class ApplyFromFindController < CandidateInterfaceController
    skip_before_action :authenticate_candidate!

    rescue_from ActionController::ParameterMissing, with: :render_not_found

    def show
      service = ApplyFromFindPage.new(provider_code: params[:providerCode],
                                      course_code: params[:courseCode],
                                      can_apply_on_apply: false,
                                      course_on_find: false,
                                      course: nil)
      service.determine_whether_course_is_on_find_or_apply
      @course = service.course

      if service.can_apply_on_apply?
        @apply_on_ucas_or_apply = CandidateInterface::ApplyOnUcasOrApplyForm.new(
          provider_code: params[:providerCode], course_code: params[:courseCode],
        )

        render :apply_on_ucas_or_apply
      elsif service.course_on_find?
        render :apply_on_ucas_only
      else
        render_not_found
      end
    end

    def ucas_or_apply
      @apply_on_ucas_or_apply = CandidateInterface::ApplyOnUcasOrApplyForm.new(apply_on_ucas_or_apply_params)

      service = ApplyFromFindPage.new(provider_code: @apply_on_ucas_or_apply.provider_code,
        course_code: @apply_on_ucas_or_apply.course_code,
        can_apply_on_apply: false,
        course_on_find: false,
        course: nil,
      )

      service.determine_whether_course_is_on_find_or_apply
      @course = service.course

      if @apply_on_ucas_or_apply.valid?
        if @apply_on_ucas_or_apply.ucas?
          redirect_to UCAS.apply_url
        else
          redirect_to candidate_interface_eligibility_path(providerCode: @apply_on_ucas_or_apply.provider_code, course_code: @apply_on_ucas_or_apply.course_code)
        end
      else
        render :apply_on_ucas_or_apply
      end
    end

  private

    def render_not_found
      render :not_found, status: :not_found
    end

    def apply_on_ucas_or_apply_params
      params.require(:candidate_interface_apply_on_ucas_or_apply_form)
        .permit(:service, :provider_code, :course_code)
    end
  end
end

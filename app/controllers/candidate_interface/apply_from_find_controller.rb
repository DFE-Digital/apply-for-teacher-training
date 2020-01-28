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
        render :apply_on_ucas_or_apply
      elsif service.course_on_find?
        render :apply_on_ucas_only
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

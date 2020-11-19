module CandidateInterface
  class OtherQualifications::DestroyController < OtherQualifications::BaseController
    before_action :render_application_feedback_component, except: %i[confirm_destroy destroy]
    def confirm_destroy
      @qualification = OtherQualificationDetailForm.build_from_qualification(current_qualification)
    end

    def destroy
      current_qualification.destroy!
      current_application.update!(other_qualifications_completed: false)

      redirect_to candidate_interface_review_other_qualifications_path
    end
  end
end

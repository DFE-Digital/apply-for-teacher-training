module CandidateInterface
  class OtherQualifications::DestroyController < OtherQualifications::BaseController
    before_action :render_application_feedback_component, except: %i[confirm_destroy destroy]

    def confirm_destroy
      @qualification = OtherQualificationDetailsForm.build_from_qualification(current_qualification)
    end

    def destroy
      current_qualification.destroy!
      current_application.update!(other_qualifications_completed: false)

      if current_application.application_qualifications.other.count.zero?

        redirect_to candidate_interface_other_qualification_type_path
      else

        redirect_to candidate_interface_review_other_qualifications_path
      end
    end
  end
end

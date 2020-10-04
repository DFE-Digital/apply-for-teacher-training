module CandidateInterface
  class OtherQualifications::DestroyController < OtherQualifications::BaseController
    def confirm_destroy
      current_qualification = current_application.application_qualifications.other.find(current_other_qualification_id)
      @qualification = OtherQualificationWizard.build_from_qualification(current_qualification)
    end

    def destroy
      current_qualification.destroy!
      current_application.update!(other_qualifications_completed: false)

      redirect_to candidate_interface_review_other_qualifications_path
    end
  end
end

module CandidateInterface
  class Volunteering::DestroyController < Volunteering::BaseController
    def confirm_destroy
      current_experience = current_application.application_volunteering_experiences.find(current_volunteering_role_id)
      @volunteering_role = VolunteeringRoleForm.build_from_experience(current_experience)
    end

    def destroy
      current_application
        .application_volunteering_experiences
        .find(current_volunteering_role_id)
        .destroy!

      if current_application.application_volunteering_experiences.blank?
        current_application.update!(volunteering_completed: nil)
        redirect_to candidate_interface_volunteering_experience_path
      else
        redirect_to candidate_interface_review_volunteering_path
      end
    end
  end
end

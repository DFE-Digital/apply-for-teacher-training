module CandidateInterface
  class Volunteering::DestroyController < CandidateInterfaceController
    def confirm_destroy
      @volunteering_role = VolunteeringRoleForm.build_from_application(current_application, current_volunteering_role_id)
    end

    def destroy
      current_application
        .application_volunteering_experiences
        .find(current_volunteering_role_id)
        .destroy!

      redirect_to candidate_interface_review_volunteering_path
    end

  private

    def current_volunteering_role_id
      params.permit(:id)[:id]
    end
  end
end

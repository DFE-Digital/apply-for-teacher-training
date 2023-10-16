module CandidateInterface
  class Volunteering::DestroyController < Volunteering::BaseController
    before_action :set_current_experience
    before_action :redirect_to_review_page, unless: -> { @current_experience }

    def confirm_destroy
      @volunteering_role = VolunteeringRoleForm.build_from_experience(@current_experience)
    end

    def destroy
      @current_experience.destroy!

      if current_application.application_volunteering_experiences.blank?
        current_application.update!(volunteering_completed: nil)
        redirect_to candidate_interface_volunteering_experience_path
      else
        redirect_to candidate_interface_review_volunteering_path
      end
    end

  private

    def set_current_experience
      @current_experience = current_application
        .application_volunteering_experiences
        .find_by(id: current_volunteering_role_id)
    end

    def redirect_to_review_page
      redirect_to candidate_interface_review_volunteering_path
    end
  end
end

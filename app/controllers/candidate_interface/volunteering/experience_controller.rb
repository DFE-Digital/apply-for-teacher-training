module CandidateInterface
  class Volunteering::ExperienceController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def show
      @volunteering_experience_form = VolunteeringExperienceForm.new
    end

    def submit
      @volunteering_experience_form = VolunteeringExperienceForm.new(volunteering_experience_form_params)

      if @volunteering_experience_form.valid?
        if @volunteering_experience_form.experience == 'false'
          redirect_to candidate_interface_review_volunteering_path
        else
          redirect_to candidate_interface_new_volunteering_role_path
        end
      else
        render :show
      end
    end

  private

    def volunteering_experience_form_params
      return nil unless params.has_key?(:candidate_interface_volunteering_experience_form)

      params.require(:candidate_interface_volunteering_experience_form).permit(
        :experience,
      )
        .transform_values(&:strip)
    end
  end
end

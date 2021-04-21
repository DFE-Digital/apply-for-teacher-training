module CandidateInterface
  class Volunteering::StartController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def show
      @volunteering_experience_form = VolunteeringExperienceForm.new(
        experience: current_application.volunteering_experience,
      )
    end

    def submit
      @volunteering_experience_form = VolunteeringExperienceForm.new(volunteering_experience_form_params)

      if @volunteering_experience_form.valid?
        @volunteering_experience_form.save(current_application)

        if @volunteering_experience_form.experience == 'false'
          redirect_to candidate_interface_review_volunteering_path
        else
          redirect_to candidate_interface_new_volunteering_role_path
        end
      else
        track_validation_error(@volunteering_experience_form)
        render :show
      end
    end

  private

    def volunteering_experience_form_params
      return nil unless params.key?(:candidate_interface_volunteering_experience_form)

      strip_whitespace params.require(:candidate_interface_volunteering_experience_form).permit(
        :experience,
      )
    end
  end
end

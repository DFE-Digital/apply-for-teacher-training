module CandidateInterface
  class Volunteering::ReviewController < Volunteering::BaseController
    def show
      @application_form = current_application
      @section_complete_form = SectionCompleteForm.new(completed: current_application.volunteering_completed)
    end

    def complete
      @application_form = current_application
      @section_complete_form = SectionCompleteForm.new(form_params)

      if @section_complete_form.save(current_application, :volunteering_completed)
        if current_application.meets_conditions_for_adviser_interruption? && @section_complete_form.completed?
          redirect_to candidate_interface_adviser_sign_ups_interruption_path
        else
          redirect_to_candidate_root
        end
      else
        track_validation_error(@section_complete_form)
        render :show
      end
    end

  private

    def form_params
      strip_whitespace params.fetch(:candidate_interface_section_complete_form, {}).permit(:completed)
    end
  end
end

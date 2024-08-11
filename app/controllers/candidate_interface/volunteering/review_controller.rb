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
        redirect_to_new_continuous_applications_if_eligible
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

module CandidateInterface
  class RestructuredWorkHistory::ReviewController < RestructuredWorkHistory::BaseController
    def show
      @application_form = current_application
      @section_complete_form = SectionCompleteForm.new(completed: current_application.work_history_completed)
    end

    def complete
      @section_complete_form = SectionCompleteForm.new(form_params)

      if @section_complete_form.save(current_application, :work_history_completed)
        redirect_to candidate_interface_application_form_path
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

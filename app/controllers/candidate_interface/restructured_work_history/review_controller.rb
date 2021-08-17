module CandidateInterface
  class RestructuredWorkHistory::ReviewController < RestructuredWorkHistory::BaseController
    def show
      @application_form = current_application
      @section_complete_form = SectionCompleteForm.new(completed: current_application.work_history_completed)
      @return_to = return_to_after_edit(default: candidate_interface_application_form_path)
    end

    def complete
      @application_form = current_application
      @section_complete_form = SectionCompleteForm.new(form_params)
      @return_to = return_to_after_edit(default: candidate_interface_application_form_path)

      if @section_complete_form.save(current_application, :work_history_completed)
        redirect_to @return_to[:back_path]
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

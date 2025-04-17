module CandidateInterface
  class RestructuredWorkHistory::ReviewController < RestructuredWorkHistory::BaseController
    def show
      @application_form = current_application
      @section_complete_form = SectionCompleteForm.new(completed: current_application.work_history_completed)
      @return_to = return_to_after_edit(default: application_form_path)
    end

    def complete
      @application_form = current_application
      @section_complete_form = SectionCompleteForm.new(form_params)
      @return_to = return_to_after_edit(default: candidate_interface_details_path)

      if @section_complete_form.save(current_application, :work_history_completed)
        if current_application.meets_conditions_for_adviser_interruption? && ActiveModel::Type::Boolean.new.cast(@section_complete_form.completed)
          redirect_to candidate_interface_adviser_sign_ups_interruption_path(@current_application.id)
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

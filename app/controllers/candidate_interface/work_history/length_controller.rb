module CandidateInterface
  class WorkHistory::LengthController < WorkHistory::BaseController
    def show
      @work_details_form = WorkHistoryForm.new
      current_application.update!(feature_restructured_work_history: false)
    end

    def submit
      @work_details_form = WorkHistoryForm.new(work_history_form_params)

      if @work_details_form.valid?
        if @work_details_form.work_history == 'missing'
          redirect_to candidate_interface_work_history_explanation_path
        else
          redirect_to candidate_interface_new_work_history_path
        end
      else
        track_validation_error(@work_details_form)
        render :show
      end
    end

  private

    def work_history_form_params
      return nil unless params.key?(:candidate_interface_work_history_form)

      strip_whitespace params.require(:candidate_interface_work_history_form).permit(:work_history)
    end
  end
end

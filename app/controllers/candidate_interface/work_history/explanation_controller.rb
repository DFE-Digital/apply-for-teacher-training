module CandidateInterface
  class WorkHistory::ExplanationController < WorkHistory::BaseController
    def show
      @work_explanation_form = WorkExplanationForm.build_from_application(
        current_application,
      )
    end

    def submit
      @work_explanation_form = WorkExplanationForm.new(work_explanation_form_params)

      if @work_explanation_form.save(current_application)
        redirect_to candidate_interface_work_history_show_path
      else
        track_validation_error(@work_explanation_form)
        render :show
      end
    end

  private

    def work_explanation_form_params
      return nil unless params.key?(:candidate_interface_work_explanation_form)

      strip_whitespace params.require(:candidate_interface_work_explanation_form).permit(
        :work_history_explanation,
      )
    end
  end
end

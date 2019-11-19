module CandidateInterface
  class WorkHistory::ExplanationController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

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
        render :show
      end
    end

  private

    def work_explanation_form_params
      return nil unless params.has_key?(:candidate_interface_work_explanation_form)

      params.require(:candidate_interface_work_explanation_form).permit(
        :work_history_explanation,
      )
    end
  end
end

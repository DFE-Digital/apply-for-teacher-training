module CandidateInterface
  class WorkHistory::ReviewController < WorkHistory::BaseController
    def show
      redirect_to candidate_interface_work_history_length_path if current_application.application_work_experiences.blank? &&
        current_application.work_history_explanation.nil?

      @application_form = current_application
    end

    def complete
      current_application.update!(application_form_params)

      redirect_to candidate_interface_application_form_path
    end

  private

    def application_form_params
      strip_whitespace params.require(:application_form).permit(:work_history_completed)
    end
  end
end

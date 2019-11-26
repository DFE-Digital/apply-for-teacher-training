module CandidateInterface
  class WorkHistory::LengthController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def show
      @work_details_form = WorkHistoryForm.new
    end

    def submit
      @work_details_form = WorkHistoryForm.new(work_history_form_params)

      if @work_details_form.valid?
        if @work_details_form.work_history == 'missing'
          redirect_to candidate_interface_work_history_explanation_path
        else
          redirect_to candidate_interface_work_history_new_path
        end
      else
        render :show
      end
    end

  private

    def work_history_form_params
      return nil unless params.has_key?(:candidate_interface_work_history_form)

      params.require(:candidate_interface_work_history_form).permit(
        :work_history,
      )
        .transform_values(&:strip)
    end
  end
end

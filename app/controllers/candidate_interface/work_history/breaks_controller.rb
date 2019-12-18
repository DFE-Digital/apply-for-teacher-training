module CandidateInterface
  class WorkHistory::BreaksController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_not_amendable

    def edit
      @work_breaks_form = WorkBreaksForm.build_from_application(
        current_application,
      )
    end

    def update
      @work_breaks_form = WorkBreaksForm.new(work_breaks_form_params)

      if @work_breaks_form.save(current_application)
        redirect_to candidate_interface_work_history_show_path
      else
        render :edit
      end
    end

  private

    def work_breaks_form_params
      params.require(:candidate_interface_work_breaks_form).permit(
        :work_history_breaks,
      )
        .transform_values(&:strip)
    end
  end
end

module CandidateInterface
  class WorkHistory::BreaksController < WorkHistory::BaseController
    before_action :redirect_to_restructured_work_history_when_candidate_should_use_new_flow

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
        track_validation_error(@work_breaks_form)
        render :edit
      end
    end

  private

    def work_breaks_form_params
      strip_whitespace params.require(:candidate_interface_work_breaks_form).permit(:work_history_breaks)
    end
  end
end

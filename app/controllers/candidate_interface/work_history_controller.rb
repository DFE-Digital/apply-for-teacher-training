module CandidateInterface
  class WorkHistoryController < CandidateInterfaceController
    def length
      @work_details_form = WorkHistoryForm.new
    end

    def submit_length
      @work_details_form = WorkHistoryForm.new(work_history_params)

      @work_details_form.valid?
      render :length
    end

  private

    def work_history_params
      return nil unless params.has_key?(:candidate_interface_work_history_form)

      params.require(:candidate_interface_work_history_form).permit(
        :work_history,
      )
    end
  end
end

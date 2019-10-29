module CandidateInterface
  class WorkHistoryController < CandidateInterfaceController
    def length
      @work_details_form = WorkHistoryForm.new
    end

    def submit_length
      @work_details_form = WorkHistoryForm.new(work_history_params)

      if @work_details_form.valid?
        redirect_to candidate_interface_work_history_new_path
      else
        render :length
      end
    end

    def new
      @work_experience_form = WorkExperienceForm.new
    end

    def create
      @work_experience_form = WorkExperienceForm.new(work_experience_params)

      if @work_experience_form.save(current_candidate.current_application)
        redirect_to candidate_interface_work_history_show_path
      else
        render :new
      end
    end

    def show
      @application_form = current_candidate.current_application
    end

  private

    def work_history_params
      return nil unless params.has_key?(:candidate_interface_work_history_form)

      params.require(:candidate_interface_work_history_form).permit(
        :work_history,
      )
    end

    def work_experience_params
      params.require(:candidate_interface_work_experience_form)
        .permit(
          :role, :organisation, :details, :working_with_children, :commitment,
          :start_date_month, :start_date_year, :end_date_month, :end_date_year
        )
    end
  end
end

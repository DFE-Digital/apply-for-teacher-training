module CandidateInterface
  class WorkHistory::DestroyController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def confirm_destroy
      @work_experience = current_application
        .application_work_experiences.find(work_experience_params[:id])
    end

    def destroy
      current_application
        .application_work_experiences
        .find(work_experience_params[:id])
        .destroy!

      redirect_to candidate_interface_work_history_show_path
    end

  private

    def work_experience_params
      params.permit(:id)
    end
  end
end

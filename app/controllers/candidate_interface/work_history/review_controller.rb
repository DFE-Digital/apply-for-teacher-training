module CandidateInterface
  class WorkHistory::ReviewController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_not_amendable

    def show
      @application_form = current_application
    end

    def complete
      @application_form = current_application

      if @application_form.application_work_experiences.blank? && @application_form.work_history_explanation.blank?
        flash[:warning] = 'Please complete your work history or tell us why you’ve been out of the workplace'

        @application_form.work_history_completed = false

        render :show
      else
        @application_form.update!(application_form_params)

        redirect_to candidate_interface_application_form_path
      end
    end

  private

    def application_form_params
      params.require(:application_form).permit(:work_history_completed)
        .transform_values(&:strip)
    end
  end
end

module CandidateInterface
  class Degrees::ReviewController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def show
      @application_form = current_application
    end

    def complete
      @application_form = current_application

      if @application_form.application_qualifications.degrees.count.zero?
        flash[:warning] = 'You can’t mark this section complete without adding a degree.'

        @application_form.degrees_completed = false

        render :show
      else
        @application_form.update!(application_form_params)

        redirect_to candidate_interface_application_form_path
      end
    end

  private

    def application_form_params
      params.require(:application_form).permit(:degrees_completed)
        .transform_values(&:strip)
    end
  end
end

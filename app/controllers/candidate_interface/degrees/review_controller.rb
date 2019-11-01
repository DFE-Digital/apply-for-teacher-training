module CandidateInterface
  class Degrees::ReviewController < CandidateInterfaceController
    def show
      @application_form = current_candidate.current_application
    end

    def complete
      @application_form = current_candidate.current_application

      @application_form.update!(application_form_params)

      redirect_to candidate_interface_application_form_path
    end

  private

    def application_form_params
      params.require(:application_form).permit(:degrees_completed)
    end
  end
end

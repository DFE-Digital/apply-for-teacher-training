module CandidateInterface
  class RestructuredWorkHistory::ReviewController < RestructuredWorkHistory::BaseController
    def show
      @application_form = current_application
    end

    def complete
      current_application.update!(application_form_params)

      redirect_to candidate_interface_application_form_path
    end
  end
end

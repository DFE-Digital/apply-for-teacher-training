module CandidateInterface
  class UnsubmittedApplicationFormController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def show
      @application_form_presenter = CandidateInterface::ApplicationFormPresenter.new(current_application)
      @application_form = current_application
    end

    def review
      redirect_to candidate_interface_application_complete_path if current_application.submitted?
      @application_form = current_application
    end
  end
end

module CandidateInterface
  class ContinuousApplicationsController < CandidateInterfaceController
    before_action :verify_continuous_applications

  private

    def redirect_to_your_applications_if_submitted
      redirect_to candidate_interface_continuous_applications_choices_path unless application_choice.unsubmitted?
    end

    def verify_continuous_applications
      render_404 unless current_application&.continuous_applications?
    end
  end
end

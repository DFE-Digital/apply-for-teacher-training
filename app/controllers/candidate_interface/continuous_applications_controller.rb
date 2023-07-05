module CandidateInterface
  class ContinuousApplicationsController < CandidateInterfaceController
    before_action :verify_continuous_applications

  private

    def verify_continuous_applications
      render_404 unless current_application&.continuous_applications?
    end
  end
end

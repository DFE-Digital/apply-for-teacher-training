module CandidateInterface
  class RestructuredWorkHistory::BaseController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted, :render_404_if_candidate_has_used_existing_flow

  private

    def render_404_if_candidate_has_used_existing_flow
      render_404 if candidate_has_used_existing_flow?
    end

    def candidate_has_used_existing_flow?
      !current_application.feature_restructured_work_history
    end
  end
end

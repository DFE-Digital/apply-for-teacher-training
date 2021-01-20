module CandidateInterface
  class RestructuredWorkHistory::BaseController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted, :render_404_if_candidate_has_used_existing_flow_or_flag_is_active

    def show; end

  private

    def render_404_if_candidate_has_used_existing_flow_or_flag_is_active
      render_404 if candidate_has_used_existing_flow? || FeatureFlag.active?(:restructured_work_history)
    end

    def candidate_has_used_existing_flow?
      !current_application.feature_restructured_work_history
    end
  end
end

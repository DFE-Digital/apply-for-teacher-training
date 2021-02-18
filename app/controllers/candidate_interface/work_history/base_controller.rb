module CandidateInterface
  class WorkHistory::BaseController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted, :redirect_to_restructured_work_history_when_candidate_should_use_new_flow

  private

    def redirect_to_restructured_work_history_when_candidate_should_use_new_flow
      if FeatureFlag.active?(:restructured_work_history) && current_application.feature_restructured_work_history
        redirect_to candidate_interface_restructured_work_history_path
      end
    end
  end
end

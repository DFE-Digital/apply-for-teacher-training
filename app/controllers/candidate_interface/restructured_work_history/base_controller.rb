module CandidateInterface
  class RestructuredWorkHistory::BaseController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted
  end
end

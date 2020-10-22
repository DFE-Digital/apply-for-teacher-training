module CandidateInterface
  class OtherQualifications::OtherQualificationsBaseController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted
  end
end

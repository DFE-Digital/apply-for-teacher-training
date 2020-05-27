module CandidateInterface
  module CourseChoices
    class BaseController < CandidateInterfaceController
      before_action :redirect_to_dashboard_if_submitted
      rescue_from ActiveRecord::RecordNotFound, with: :render_404
    end
  end
end

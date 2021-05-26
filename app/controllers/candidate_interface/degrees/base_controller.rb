module CandidateInterface
  module Degrees
    class BaseController < CandidateInterfaceController
      before_action :redirect_to_dashboard_if_submitted
      before_action :render_application_feedback_component

      def current_degree
        current_application.application_qualifications.degrees.find_by(id: params[:id])
      end
      helper_method :current_degree
    end
  end
end

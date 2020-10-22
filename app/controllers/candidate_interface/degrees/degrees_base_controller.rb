module CandidateInterface
  module Degrees
    class DegreesBaseController < CandidateInterfaceController
      before_action :redirect_to_dashboard_if_submitted

      def current_degree
        current_application.application_qualifications.degrees.find(params[:id])
      end
    end
  end
end

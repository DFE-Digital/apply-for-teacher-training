module CandidateInterface
  module Degrees
    class BaseController < SectionController
      before_action :redirect_v23_applications_to_complete_page_if_submitted_and_not_carried_over
      before_action :render_application_feedback_component

      def current_degree
        current_application.application_qualifications.degrees.find_by(id: params[:id])
      end
      helper_method :current_degree
    end
  end
end

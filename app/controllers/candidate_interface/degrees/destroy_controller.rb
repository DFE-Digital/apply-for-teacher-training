module CandidateInterface
  module Degrees
    class DestroyController < DegreesBaseController
      before_action :redirect_to_dashboard_if_submitted

      def confirm_destroy
        @degree = current_degree
      end

      def destroy
        current_degree.destroy!
        current_application.update!(degrees_completed: false)

        if current_application.application_qualifications.degrees.blank?
          redirect_to candidate_interface_new_degree_path
        else
          redirect_to candidate_interface_degrees_review_path
        end
      end
    end
  end
end

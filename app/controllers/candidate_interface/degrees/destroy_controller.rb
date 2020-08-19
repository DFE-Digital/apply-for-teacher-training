module CandidateInterface
  module Degrees
    class DestroyController < CandidateInterfaceController
      before_action :redirect_to_dashboard_if_submitted

      def confirm_destroy
        @degree = current_application.application_qualifications.degrees.find(current_degree_id)
      end

      def destroy
        current_application
          .application_qualifications
          .find(current_degree_id)
          .destroy!

        current_application.update!(degrees_completed: false)

        if current_application.application_qualifications.degrees.blank?
          redirect_to candidate_interface_new_degree_path
        else
          redirect_to candidate_interface_degrees_review_path
        end
      end

    private

      def current_degree_id
        params.permit(:id)[:id]
      end
    end
  end
end

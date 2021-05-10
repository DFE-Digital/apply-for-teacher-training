module CandidateInterface
  module Degrees
    class DestroyController < BaseController
      before_action :render_application_feedback_component, except: %i[confirm_destroy destroy]

      def confirm_destroy
        @degree = current_degree
      end

      def destroy
        current_degree.destroy!

        if current_application.application_qualifications.degrees.blank?
          current_application.update!(degrees_completed: nil)
          redirect_to candidate_interface_new_degree_path
        else
          redirect_to candidate_interface_degrees_review_path
        end
      end
    end
  end
end

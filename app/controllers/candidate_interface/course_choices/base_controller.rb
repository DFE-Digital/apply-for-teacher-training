module CandidateInterface
  module CourseChoices
    class BaseController < CandidateInterfaceController
      before_action :redirect_to_dashboard_if_submitted, :redirect_to_dashboard_if_cycle_is_over
      rescue_from ActiveRecord::RecordNotFound, with: :render_404

    private

      def redirect_to_dashboard_if_cycle_is_over
        redirect_to candidate_interface_course_choices_review_path and return unless CandidateInterface::CanAddCourseChoice.can_add_course_choice?(application_form: current_application)
      end
    end
  end
end

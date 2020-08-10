module CandidateInterface
  module CourseChoices
    class BaseController < CandidateInterfaceController
      before_action :redirect_to_dashboard_if_submitted, :redirect_to_review_page_if_find_down
      rescue_from ActiveRecord::RecordNotFound, with: :render_404

    private

      def redirect_to_review_page_if_find_down
        redirect_to candidate_interface_course_choices_review_path if EndOfCycleTimetable.find_down?
      end
    end
  end
end

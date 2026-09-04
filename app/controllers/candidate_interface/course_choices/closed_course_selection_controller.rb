module CandidateInterface
  module CourseChoices
    class ClosedCourseSelectionController < CandidateInterface::CourseChoices::BaseController
      before_action :set_course
      skip_before_action :redirect_to_your_applications_if_maximum_amount_of_choices_have_been_used

    private

      def step_params
        params[current_step] = {
          provider_id: params.delete(:provider_id),
          course_id: params.delete(:course_id),
        }
        params
      end

      def current_step
        :closed_course_selection
      end

      def set_course
        @course = @wizard.course
      end

      def wizard_controller?
        true
      end
    end
  end
end

module CandidateInterface
  module CourseChoices
    class FullCourseSelectionController < CandidateInterface::CourseChoices::BaseController
      before_action :set_course
      skip_before_action :redirect_to_your_applications_if_maximum_amount_of_choices_have_been_used

    private

      def current_step
        :full_course_selection
      end

      def set_course
        @course = @wizard.course
      end
    end
  end
end

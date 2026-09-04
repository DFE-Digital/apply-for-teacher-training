module CandidateInterface
  module CourseChoices
    class WhichCourseAreYouApplyingToController < CandidateInterface::CourseChoices::BaseController
    private

      def current_step
        :which_course_are_you_applying_to
      end

      def wizard_controller?
        true
      end
    end
  end
end

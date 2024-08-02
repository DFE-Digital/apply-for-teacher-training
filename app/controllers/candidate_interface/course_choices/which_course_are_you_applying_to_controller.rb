module CandidateInterface
  module CourseChoices
    class WhichCourseAreYouApplyingToController < CandidateInterface::CourseChoices::BaseController
    private

      def current_step
        :which_course_are_you_applying_to
      end
    end
  end
end

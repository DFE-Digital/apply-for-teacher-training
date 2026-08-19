module CandidateInterface
  module CourseChoices
    class CourseStudyModeController < CandidateInterface::CourseChoices::BaseController
      include CandidateInterface::CourseChoices::Concerns::DuplicateCourseRedirect

    private

      def current_step
        :course_study_mode
      end

      def wizard_controller?
        true
      end
    end
  end
end

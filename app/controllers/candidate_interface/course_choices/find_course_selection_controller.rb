module CandidateInterface
  module CourseChoices
    class FindCourseSelectionController < CandidateInterface::CourseChoices::BaseController
      include CandidateInterface::CourseChoices::Concerns::DuplicateCourseRedirect
      include CandidateInterface::CourseChoices::Concerns::FullCourseRedirect

    private

      def current_step
        :find_course_selection
      end
    end
  end
end

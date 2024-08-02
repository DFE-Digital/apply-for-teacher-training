module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class FindCourseSelectionController < BaseController
        include CandidateInterface::CourseChoices::Concerns::DuplicateCourseRedirect
        include CandidateInterface::CourseChoices::Concerns::FullCourseRedirect

      private

        def current_step
          :find_course_selection
        end
      end
    end
  end
end

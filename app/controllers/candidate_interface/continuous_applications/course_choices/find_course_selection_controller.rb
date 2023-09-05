module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class FindCourseSelectionController < BaseController
      private

        def current_step
          :find_course_selection
        end
      end
    end
  end
end

module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class WhichCourseAreYouApplyingToController < BaseController
      private

        def current_step
          :which_course_are_you_applying_to
        end
      end
    end
  end
end

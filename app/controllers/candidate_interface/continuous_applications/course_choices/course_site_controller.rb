module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class CourseSiteController < BaseController
        include CandidateInterface::CourseChoices::Concerns::DuplicateCourseRedirect

      private

        def current_step
          :course_site
        end
      end
    end
  end
end

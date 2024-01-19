module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class BlockedSubmissionsController < ::CandidateInterface::ContinuousApplicationsController
        def show
          @max_course_choices = current_application.number_of_choices_candidate_can_make
        end
      end
    end
  end
end

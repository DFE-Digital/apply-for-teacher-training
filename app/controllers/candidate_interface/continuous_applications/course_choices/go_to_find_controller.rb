module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class GoToFindController < ::CandidateInterface::ContinuousApplicationsController
        def new
          @wizard = CourseSelectionWizard.new(current_step:, request:)
        end

      private

        def current_step
          :go_to_find_explanation
        end
      end
    end
  end
end

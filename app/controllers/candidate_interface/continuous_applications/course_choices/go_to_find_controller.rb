module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class GoToFindController < ::CandidateInterface::ContinuousApplicationsController
        def new
          @wizard = CourseSelectionWizard.new(current_step:)
          @adviser_sign_up = Adviser::SignUp.new(current_application)
        end

      private

        def current_step
          :go_to_find_explanation
        end
      end
    end
  end
end

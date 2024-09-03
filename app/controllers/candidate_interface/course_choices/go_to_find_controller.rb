module CandidateInterface
  module CourseChoices
    class GoToFindController < CandidateInterfaceController
      include CandidateInterface::ContinuousApplications
      def new
        @wizard = CourseSelection::CourseSelectionWizard.new(current_step:)
        @adviser_sign_up = Adviser::SignUp.new(current_application)
      end

    private

      def current_step
        :go_to_find_explanation
      end
    end
  end
end

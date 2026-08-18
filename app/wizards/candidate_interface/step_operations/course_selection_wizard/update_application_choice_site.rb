module CandidateInterface
  module StepOperations
    class CourseSelectionWizard::UpdateApplicationChoiceSite < CourseSelectionWizard::Base
      def execute
        { success: true }
      end
    end
  end
end

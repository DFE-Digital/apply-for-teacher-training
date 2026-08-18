module CandidateInterface
  module StepOperations
    class CourseSelectionWizard::SubmitApplicationChoice < CourseSelectionWizard::Base
      def execute
        { success: true }
      end
    end
  end
end

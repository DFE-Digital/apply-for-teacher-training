module CandidateInterface
  module StepOperations
    class CourseSelectionWizard::UpdateApplicationChoiceStudyMode < CourseSelectionWizard::Base
      def execute
        { success: true }
      end
    end
  end
end

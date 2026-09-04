module CandidateInterface
  module StepOperations
    class CourseSelectionWizard::UpdateApplicationChoiceVisa < CourseSelectionWizard::Base
      delegate :application_choice, :state_store, to: :wizard
      delegate :visa_explanation, :visa_explanation_details, to: :state_store

      def execute
        application_choice.update(
          visa_explanation: visa_explanation,
          visa_explanation_details: visa_explanation_details,
        )
        { success: true, application_choice_id: application_choice.id }
      end
    end
  end
end

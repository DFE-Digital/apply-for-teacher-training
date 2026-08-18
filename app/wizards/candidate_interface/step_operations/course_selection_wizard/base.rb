module CandidateInterface
  module StepOperations
    class CourseSelectionWizard::Base
      attr_reader :step, :wizard

      delegate :current_application, :state_store, :current_step_name, :current_step, to: :wizard

      def initialize(repository:, step:)
        @step = step
        @wizard = step.wizard
      end
    end
  end
end

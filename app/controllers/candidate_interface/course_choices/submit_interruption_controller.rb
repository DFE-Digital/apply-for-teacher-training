module CandidateInterface
  module CourseChoices
    class SubmitInterruptionController < CandidateInterfaceController
      after_action :verify_authorized
      after_action :verify_policy_scoped

      def show
        authorize %i[candidate_interface course_choices submit_interruption], :show?
        @application_choice = policy_scope(ApplicationChoice).find(
          params.expect(:application_choice_id),
        )
      end
    end
  end
end

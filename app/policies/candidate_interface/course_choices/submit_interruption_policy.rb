module CandidateInterface
  module CourseChoices
    class SubmitInterruptionPolicy < ApplicationPolicy
      def show?
        current_application.international_applicant? ||
          current_application.international_qualification?
      end
    end
  end
end

module CandidateInterface
  class ApplicationReferencePolicy < ApplicationPolicy
    alias reference record

    def show_cancel_link?
      reference.feedback_requested?
    end

    def cancel?
      current_application.application_references.feedback_provided.any? ||
        current_application.application_references.feedback_requested.many?
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        scope.where(application_form_id: current_application.id)
          .includes(:application_form)
      end
    end
  end
end

module CandidateInterface
  class ApplicationReferencePolicy < ApplicationPolicy
    alias reference record

    def edit?
      # currently only applied to references pre-submission --> to be elaborated on when applied to refs post-submission
      reference.not_requested_yet?
    end

    def show_cancel_link?
      reference.feedback_requested?
    end

    def cancel?
      reference.application_form.application_references.feedback_provided.any? ||
        reference.application_form.application_references.feedback_requested.many?
    end

    def delete?
      # currently only applied to references pre-submission --> to be elaborated on when applied to refs post-submission
      reference.not_requested_yet?
    end

    def can_request?
      reference.application_form.application_choices.any?(&:accepted_choice?)
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        application_form_ids = current_candidate.active_application_forms.pluck(:id)
        scope.where(application_form_id: application_form_ids).includes(:application_form)
      end
    end
  end
end

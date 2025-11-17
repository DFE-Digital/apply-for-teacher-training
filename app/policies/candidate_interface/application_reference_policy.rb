module CandidateInterface
  class ApplicationReferencePolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        scope.where(application_form_id: user.current_application.id)
      end
    end

    def editable?
      record.any_offer_accepted? ||
        record.application_choices.all?(&:unsubmitted?)
    end

    def deletable?
      editable?
    end

    def edit?
      !record.duplicate? && record.not_requested_yet?
    end

    def update?
      edit?
    end
  end
end

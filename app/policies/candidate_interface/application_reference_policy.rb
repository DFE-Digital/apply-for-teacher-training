module CandidateInterface
  class ApplicationReferencePolicy < ApplicationPolicy
    alias application_form record
    alias application_reference record

    # attr_reader :user, :record, :applicastion_form
    #
    # def initialize(user, record, applicastion_form = nil)
    #   @user = user
    #   @record = record
    #   @applicastion_form = applicastion_form
    # end

    def edit?
      !application_reference.duplicate? && application_reference.not_requested_yet?
    end

    def update?
      edit?
    end

    def editable?
      application_form.any_offer_accepted? ||
        application_form.application_choices.all?(&:unsubmitted?)
    end

    def deletable?
      editable?
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        scope.where(application_form_id: user.current_application.id)
      end
    end
  end
end

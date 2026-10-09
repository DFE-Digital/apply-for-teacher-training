module CandidateInterface
  class OfferDashboardPolicy < ApplicationPolicy
    def show?
      any_offer_pending_conditions? || any_application_recruited? || any_deferred_offer?
    end

  private

    def any_offer_pending_conditions?
      active_application_choices.pluck(:status).include?('pending_conditions')
    end

    def any_application_recruited?
      active_application_choices.pluck(:status).include?('recruited')
    end

    def any_deferred_offer?
      active_application_choices.pluck(:status).include?('offer_deferred')
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        scope.where(application_form_id: current_application.id).creation_order
      end
    end
  end
end

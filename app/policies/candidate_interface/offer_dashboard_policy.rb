module CandidateInterface
  class OfferDashboardPolicy < ApplicationPolicy
    def show?
      any_offer_pending_conditions? || current_application.recruited? || any_deferred_offer?
    end

  private

    def any_offer_pending_conditions?
      current_application.application_choices.map(&:status).include?('pending_conditions')
    end

    def any_deferred_offer?
      current_application.application_choices.map(&:status).include?('offer_deferred')
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        scope.where(application_form_id: current_application.id).creation_order
      end
    end
  end
end

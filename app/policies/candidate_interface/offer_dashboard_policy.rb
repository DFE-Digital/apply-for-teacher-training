module CandidateInterface
  class OfferDashboardPolicy < ApplicationPolicy
    def show?
      any_accepted_offer? || current_application.recruited? || any_deferred_offer?
    end

  private

    def any_accepted_offer?
      current_application.application_choices.map(&:status).include?('pending_conditions')
    end

    def any_deferred_offer?
      current_application.application_choices.map(&:status).include?('offer_deferred')
    end
  end
end

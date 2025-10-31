module ProviderInterface
  module ApplicationHeaderComponents
    class DeferredOfferComponent < ApplicationChoiceHeaderComponent
      def deferred_offer_wizard_applicable?
        provider_can_respond &&
          application_choice.status == 'offer_deferred' &&
          application_choice.recruitment_cycle == previous_year
      end

      def deferred_offer_in_current_cycle?
        application_choice.status == 'offer_deferred' &&
          application_choice.recruitment_cycle == current_year
      end

      def deferred_offer_but_cannot_respond?
        !provider_can_respond &&
          application_choice.status == 'offer_deferred' &&
          application_choice.recruitment_cycle == previous_year
      end

      def previous_year
        @previous_year ||= RecruitmentCycleTimetable.previous_year
      end

      def current_year
        @current_year ||= RecruitmentCycleTimetable.current_year
      end
    end
  end
end

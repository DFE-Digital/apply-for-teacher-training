module ProviderInterface
  module ApplicationHeaderComponents
    class DeferredOfferComponent < ApplicationChoiceHeaderComponent
      def deferred_offer_wizard_applicable?
        provider_can_respond &&
          application_choice.status == 'offer_deferred' &&
          application_choice.recruitment_cycle == RecruitmentCycle.previous_year
      end

      def deferred_offer_in_current_cycle?
        application_choice.status == 'offer_deferred' &&
          application_choice.recruitment_cycle == RecruitmentCycle.current_year &&
          !application_choice.current_course_option.in_next_cycle
      end

      def deferred_offer_but_cannot_respond?
        !provider_can_respond &&
          application_choice.status == 'offer_deferred' &&
          application_choice.recruitment_cycle == RecruitmentCycle.previous_year
      end
    end
  end
end

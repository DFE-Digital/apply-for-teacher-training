module ProviderInterface
  module Offer
    class ConditionsController < OffersController
      def new
        @wizard = OfferWizard.new(offer_store, { current_step: 'conditions', action: action })
        @wizard.save_state!
      end

      def create
        @wizard = OfferWizard.new(offer_store, conditions_params.to_h)

        if @wizard.valid_for_current_step?
          @wizard.save_state!

          redirect_to [:new, :provider_interface, @application_choice, :offer, @wizard.next_step]
        else
          render :new
        end
      end

    private

      def conditions_params
        params.require(:provider_interface_offer_wizard).permit(:further_condition_1, :further_condition_2,
                                                                :further_condition_3, :further_condition_4,
                                                                standard_conditions: [])
      end
    end
  end
end

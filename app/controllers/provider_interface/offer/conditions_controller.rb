module ProviderInterface
  module Offer
    class ConditionsController < ProviderInterface::OffersController

      def new
        @wizard = OfferWizard.new(offer_store, {current_step: 'conditions'})
        @wizard.save_state!
      end

      def create
        @wizard = OfferWizard.new(offer_store, conditions_params)
        if @wizard.valid?
          redirect_to provider_interface_offer_review_path(@application_choice)
        else
          render 'new'
        end
      end

      private

      def conditions_params
        params.require(:provider_interface_offer_wizard).permit(conditions: [])
      end
    end
  end
end

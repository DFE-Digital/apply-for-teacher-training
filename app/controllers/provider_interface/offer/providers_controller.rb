module ProviderInterface
  module Offer
    class ProvidersController < OffersController
      def new
        @wizard = OfferWizard.new(offer_store, { decision: 'change_offer', current_step: 'providers', action: action })
        @wizard.save_state!

        @providers = available_providers
      end

      def create
        @wizard = OfferWizard.new(offer_store, provider_params.to_h.merge!(decision: 'change_offer', current_step: 'providers'))

        if @wizard.valid_for_current_step?
          @wizard.save_state!

          redirect_to [:new, :provider_interface, @application_choice, :offer, @wizard.next_step]
        else
          @providers = available_providers

          render :new
        end
      end

      def edit
        @wizard = OfferWizard.new(offer_store, { current_step: 'providers', action: action })
        @wizard.save_state!

        @providers = available_providers
      end

      def update
        @wizard = OfferWizard.new(offer_store, provider_params.to_h.merge!(current_step: 'providers'))

        if @wizard.valid_for_current_step?
          @wizard.save_state!

          redirect_to [:edit, :provider_interface, @application_choice, :offer, @wizard.next_step]
        else
          @providers = available_providers

          render :edit
        end
      end

    private

      def provider_params
        params.require(:provider_interface_offer_wizard).permit(:provider_id)
      end
    end
  end
end

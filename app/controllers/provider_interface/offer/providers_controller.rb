module ProviderInterface
  module Offer
    class ProvidersController < OffersController
      def new
        @wizard = OfferWizard.new(offer_store, { decision: 'change_offer', current_step: 'providers', action: })
        @wizard.save_state!

        @providers = available_providers
      end

      def edit
        @wizard = OfferWizard.new(offer_store, { current_step: 'providers', action: })
        @wizard.save_state!

        @providers = available_providers
      end

      def create
        @wizard = OfferWizard.new(offer_store, attributes_for_wizard)

        if @wizard.valid_for_current_step?
          @wizard.save_state!

          redirect_to [:new, :provider_interface, @application_choice, :offer, @wizard.next_step]
        else
          @providers = available_providers
          track_validation_error(@wizard)

          render :new
        end
      end

      def update
        @wizard = OfferWizard.new(offer_store, attributes_for_wizard)

        if @wizard.valid_for_current_step?
          @wizard.save_state!

          redirect_to [:edit, :provider_interface, @application_choice, :offer, @wizard.next_step]
        else
          track_validation_error(@wizard)
          @providers = available_providers

          render :edit
        end
      end

    private

      def provider_params
        params.require(:provider_interface_offer_wizard).permit(:provider_id)
      end

      def attributes_for_wizard
        provider_params.to_h.merge!(current_step: 'providers')
      end
    end
  end
end

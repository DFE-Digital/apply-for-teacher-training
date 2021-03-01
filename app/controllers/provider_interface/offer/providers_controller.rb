module ProviderInterface
  module Offer
    class ProvidersController < ProviderInterface::OffersController
      def new
        @wizard = OfferWizard.new(offer_store, {current_step: 'provider'})
        @wizard.save_state!

        @providers =  current_provider_user.providers
      end

      def create
        @wizard = OfferWizard.new(offer_store, provider_params)
        @wizard.save_state!

        if @wizard.valid?
          return redirect_to [:new , :provider_interface, :offer, @wizard.next_step]
        else
          @providers = current_provider_user.providers
          render 'new'
        end
      end

      private

      def provider_params
        provider_params = params[:provider_interface_offer_wizard] || ActionController::Parameters.new
        provider_params.permit(:provider_id)
      end
    end
  end
end

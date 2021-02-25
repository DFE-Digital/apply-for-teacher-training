module ProviderInterface
  module Offer
    class LocationsController < ProviderInterface::OffersController
      def new
        @wizard = OfferWizard.new(offer_store, {current_step: 'location'})
        @wizard.save_state!
        set_locations
      end

      def create
        @wizard = OfferWizard.new(offer_store, site_id: location_params[:site_id])
        @wizard.save_state!

        if @wizard.valid?
          redirect_to []
        else
          set_locations
          render 'new'
        end
      end

      private

      def location_params
        location_params = params[:provider_interface_offer_wizard] || ActionController::Parameters.new
        location_params.permit(:site_id)
      end

      def set_locations
      end
    end
  end
end

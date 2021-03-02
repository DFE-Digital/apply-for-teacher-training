module ProviderInterface
  module Offer
    class ChecksController < OffersController
      def new
        @wizard = OfferWizard.new(offer_store, { current_step: 'check' })
        @wizard.save_state!
      end
    end
  end
end

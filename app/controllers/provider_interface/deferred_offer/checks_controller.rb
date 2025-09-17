module ProviderInterface
  module DeferredOffer
    class ChecksController < ProviderInterface::ProviderInterfaceController
      include ProviderInterface::DeferredOffer::Navigation

      def show
        @deferred_offer = DeferredOfferConfirmation.find_or_initialize_by(
          provider_user: current_provider_user,
          offer: offer,
        )
      end
    end
  end
end

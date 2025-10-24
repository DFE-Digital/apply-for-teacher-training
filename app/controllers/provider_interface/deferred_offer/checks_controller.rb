module ProviderInterface
  module DeferredOffer
    class ChecksController < ProviderInterface::ProviderInterfaceController
      include ProviderInterface::DeferredOffer::Navigation

      def show
        @deferred_offer = DeferredOfferConfirmation.find_or_initialize_by(
          provider_user: current_provider_user,
          offer: offer,
          offered_course_option: offer.application_choice.current_course_option,
        )
      end
    end
  end
end

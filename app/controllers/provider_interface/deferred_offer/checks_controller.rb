module ProviderInterface
  module DeferredOffer
    class ChecksController < ProviderInterface::ProviderInterfaceController
      def show
        @deferred_offer = DeferredOfferConfirmation.find_or_initialize_by(
          provider_user: current_provider_user,
          offer: offer,
        ) do |deferred_offer|
          deferred_offer.course = offer.course
          deferred_offer.location = offer.site
          deferred_offer.study_mode = offer.study_mode
        end
      end

    private

      def offer
        application_choice.offer
      end

      def application_choice
        @application_choice ||= GetApplicationChoicesForProviders.call(
          providers: current_provider_user.providers,
        ).find(params.require(:application_choice_id))
      end
    end
  end
end

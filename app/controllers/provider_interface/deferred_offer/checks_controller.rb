module ProviderInterface
  module DeferredOffer
    class ChecksController < ProviderInterface::ProviderInterfaceController
      def show
        application_choice = GetApplicationChoicesForProviders.call(
          providers: current_provider_user.providers,
        ).find(params.require(:application_choice_id))

        offer = application_choice.offer

        @deferred_offer = ProviderInterface::ConfirmDeferredOfferForm.new(
          course_id: offer.course.id,
          location_id: offer.site.id,
          study_mode: offer.study_mode,
          conditions: offer.conditions || [],
          application_choice: application_choice,
        )
      end
    end
  end
end

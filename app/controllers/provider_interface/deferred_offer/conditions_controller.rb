module ProviderInterface
  module DeferredOffer
    class ConditionsController < ProviderInterface::ProviderInterfaceController
      def edit
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
          offer_conditions_status: application_choice.offer&.all_conditions_met? ? :met : :pending,
        )
      end

      def update
        # Save the answer to the question
        # If there are no validation errors,
        #   Confirm the deferral and redirect to the Application Show page
        # Else there are validation errors, re-render the page with error messages
      end
    end
  end
end

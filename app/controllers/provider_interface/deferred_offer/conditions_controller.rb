module ProviderInterface
  module DeferredOffer
    class ConditionsController < ProviderInterface::ProviderInterfaceController
      # TODO: must have "make decisions" permission
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
        application_choice = GetApplicationChoicesForProviders.call(
          providers: current_provider_user.providers,
        ).find(params.require(:application_choice_id))

        offer = application_choice.offer

        defaults = {
          course_id: offer.course.id,
          location_id: offer.site.id,
          study_mode: offer.study_mode,
          conditions: offer.conditions || [],
          application_choice: application_choice,
          offer_conditions_status: application_choice.offer&.all_conditions_met? ? :met : :pending,
        }

        @deferred_offer = ProviderInterface::ConfirmDeferredOfferForm.new(deferred_offer_params.merge(defaults))

        # Save the answer to the question
        if @deferred_offer.save && @deferred_offer.confirm_offer(current_provider_user)
          # If there are no validation errors,
          #   Confirm the deferral and redirect to the Application Show page
          redirect_to provider_interface_application_choice_path(application_choice), success: 'Deferred offer successfully confirmed for current cycle'
        else
          # Else there are validation errors, re-render the page with error messages
          render :edit, status: :unprocessable_entity
        end
      end

      private

      def deferred_offer_params
        params.expect(provider_interface_confirm_deferred_offer_form: [:conditions_status])
      end
    end
  end
end

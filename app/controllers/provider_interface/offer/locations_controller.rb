module ProviderInterface
  module Offer
    class LocationsController < OffersController
      def new
        @wizard = OfferWizard.new(offer_store, { decision: 'change_offer', current_step: 'locations', action: action })
        @wizard.save_state!

        @course_options = available_course_options(@wizard.course_id, @wizard.study_mode).includes([:site])
      end

      def create
        @wizard = OfferWizard.new(offer_store, course_option_params.to_h.merge(decision: 'change_offer', current_step: 'locations'))

        if @wizard.valid_for_current_step?
          @wizard.save_state!

          redirect_to [:new, :provider_interface, @application_choice, :offer, @wizard.next_step]
        else
          @course_options = available_course_options(@wizard.course_id, @wizard.study_mode)

          render :new
        end
      end

      def edit
        @wizard = OfferWizard.new(offer_store, { current_step: 'locations', action: action })
        @wizard.save_state!

        @course_options = available_course_options(@wizard.course_id, @wizard.study_mode).includes([:site])
      end

      def update
        @wizard = OfferWizard.new(offer_store, course_option_params.to_h.merge(current_step: 'locations'))

        if @wizard.valid_for_current_step?
          @wizard.save_state!

          redirect_to [:edit, :provider_interface, @application_choice, :offer, @wizard.next_step]
        else
          @course_options = available_course_options(@wizard.course_id, @wizard.study_mode)

          render :edit
        end
      end

    private

      def course_option_params
        params.require(:provider_interface_offer_wizard).permit(:course_option_id)
      end
    end
  end
end

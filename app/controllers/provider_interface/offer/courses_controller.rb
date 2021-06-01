module ProviderInterface
  module Offer
    class CoursesController < OffersController
      def new
        @wizard = OfferWizard.new(offer_store, { decision: 'change_offer', current_step: 'courses', action: action })
        @wizard.save_state!

        @courses = available_courses(@wizard.provider_id)
      end

      def create
        @wizard = OfferWizard.new(offer_store, attributes_for_wizard)

        if @wizard.valid_for_current_step?
          @wizard.save_state!

          redirect_to [:new, :provider_interface, @application_choice, :offer, @wizard.next_step]
        else
          @courses = available_courses(@wizard.provider_id)
          track_validation_error(@wizard)

          render :new
        end
      end

      def edit
        @wizard = OfferWizard.new(offer_store, { current_step: 'courses', action: action })
        @wizard.save_state!

        @courses = available_courses(@wizard.provider_id)
      end

      def update
        @wizard = OfferWizard.new(offer_store, attributes_for_wizard)

        if @wizard.valid_for_current_step?
          @wizard.save_state!

          redirect_to [:edit, :provider_interface, @application_choice, :offer, @wizard.next_step]
        else
          @courses = available_courses(@wizard.provider_id)
          track_validation_error(@wizard)

          render :edit
        end
      end

    private

      def course_params
        params.require(:provider_interface_offer_wizard).permit(:course_id)
      end

      def attributes_for_wizard
        course_params.to_h.merge!(current_step: 'courses')
      end
    end
  end
end

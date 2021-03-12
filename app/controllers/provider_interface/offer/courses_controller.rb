module ProviderInterface
  module Offer
    class CoursesController < OffersController
      def new
        @wizard = OfferWizard.new(offer_store, { decision: 'change_offer', current_step: 'courses' })
        @wizard.save_state!

        @courses = available_courses(@wizard.provider_id)
      end

      def create
        @wizard = OfferWizard.new(offer_store, course_params.to_h)

        if @wizard.valid_for_current_step?
          @wizard.save_state!

          redirect_to [:new, :provider_interface, @application_choice, :offer, @wizard.next_step]
        else
          @courses = available_courses(@wizard.provider_id)

          render :new
        end
      end

    private

      def course_params
        params.require(:provider_interface_offer_wizard).permit(:course_id)
      end
    end
  end
end

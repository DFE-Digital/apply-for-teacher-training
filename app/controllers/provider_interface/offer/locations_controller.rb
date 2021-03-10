module ProviderInterface
  module Offer
    class LocationsController < OffersController
      def new
        @wizard = OfferWizard.new(offer_store, { decision: 'change_offer', current_step: 'locations' })
        @wizard.save_state!

        @course_options = CourseOption.where( course_id: @wizard.course_id,
                                             study_mode: @wizard.study_mode).
                                             includes(:site).order('sites.name')
      end

      def create
        @wizard = OfferWizard.new(offer_store, course_option_params.to_h)

        if @wizard.valid_for_current_step?
          @wizard.save_state!

          redirect_to [:new, :provider_interface, @application_choice, :offer, @wizard.next_step]
        else
          render :new
        end
      end

    private

      def course_option_params
        params.require(:provider_interface_offer_wizard).permit(:course_option_id)
      end
    end
  end
end

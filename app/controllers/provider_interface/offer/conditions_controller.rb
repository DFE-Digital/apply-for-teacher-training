module ProviderInterface
  module Offer
    class ConditionsController < OffersController
      def new
        @wizard = OfferWizard.new(offer_store, { current_step: 'conditions', action: action })
        @wizard.save_state!
      end

      def create
        @wizard = OfferWizard.new(offer_store, attributes_for_wizard)

        if @wizard.valid_for_current_step?
          @wizard.save_state!

          redirect_to [:new, :provider_interface, @application_choice, :offer, @wizard.next_step]
        else
          render :new
        end
      end

      def edit
        @wizard = OfferWizard.new(offer_store, { current_step: 'conditions', action: action })
        @wizard.save_state!
      end

      def update
        @wizard = OfferWizard.new(offer_store, attributes_for_wizard)

        if @wizard.valid_for_current_step?
          @wizard.save_state!

          redirect_to [:edit, :provider_interface, @application_choice, :offer, @wizard.next_step]
        else
          render :edit
        end
      end

    private

      def conditions_params
        params.require(:provider_interface_offer_wizard)
              .permit(further_conditions: {}, standard_conditions: [])
      end

      def attributes_for_wizard
        attributes = conditions_params

        further_conditions = conditions_params.to_h['further_conditions'].values.map { |hash| hash['text'] }

        attributes.merge!(further_conditions: further_conditions, current_step: 'conditions')
      end
    end
  end
end

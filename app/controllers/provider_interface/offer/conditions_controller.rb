module ProviderInterface
  module Offer
    class ConditionsController < OffersController
      def new
        @wizard = OfferWizard.new(offer_store, { current_step: 'conditions', action: action })
        @wizard.save_state!
      end

      def create
        @wizard = OfferWizard.new(offer_store, conditions_attributes_for_wizard.merge!(current_step: 'conditions'))

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
        @wizard = OfferWizard.new(offer_store, conditions_attributes_for_wizard.merge!(current_step: 'conditions'))

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

      def conditions_attributes_for_wizard
        params = conditions_params.to_h

        params['further_conditions'] = params['further_conditions'].values.map do |hash|
          hash['text']
        end

        params
      end
    end
  end
end

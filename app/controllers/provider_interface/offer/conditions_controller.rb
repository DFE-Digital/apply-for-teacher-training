module ProviderInterface
  module Offer
    class ConditionsController < ProviderInterfaceController
      before_action :set_application_choice

      def new
        @wizard = OfferWizard.new(offer_store, { current_step: 'conditions' })
        @wizard.save_state!
      end

      def create
        @wizard = OfferWizard.new(offer_store, conditions_params.to_h)
        @wizard.save_state!

        redirect_to [:new, :provider_interface, :offer, @wizard.next_step]
      end

    private

      def offer_store
        key = "offer_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
        WizardStateStores::RedisStore.new(key: key)
      end

      def conditions_params
        params.require(:provider_interface_offer_wizard).permit(:further_condition_1, :further_condition_2,
                                                                :further_condition_3, :further_condition_4,
                                                                standard_conditions: [])
      end
    end
  end
end

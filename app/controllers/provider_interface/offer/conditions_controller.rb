module ProviderInterface
  module Offer
    class ConditionsController < ProviderInterfaceController
      before_action :set_application_choice

      def new
        @wizard = OfferWizard.new(offer_store, { current_step: 'conditions' })
        @wizard.save_state!
      end

      def create; end

    private

      def conditions_params
        params.require(:provider_interface_offer_wizard).permit(conditions: [])
      end

      def offer_store
        key = "offer_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
        WizardStateStores::RedisStore.new(key: key)
      end
    end
  end
end

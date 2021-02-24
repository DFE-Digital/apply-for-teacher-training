module ProviderInterface
  class OffersController < ProviderInterfaceController
    before_action :set_application_choice
    before_action :requires_make_decisions_permission

    def conditions
      @wizard = OfferWizard.new(offer_store, {current_step: 'conditions'})
      @wizard.save_state!
    end

    def check
      @wizard = OfferWizard.new(offer_store, offer_conditions_params.merge!(current_step: 'check'))
      @wizard.save_state!

      render :check
    end

  private

    def offer_store
      key = "offer_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
      WizardStateStores::RedisStore.new(key: key)
    end

    def offer_conditions_params
      params.require(:provider_interface_offer_wizard).permit(conditions: [])
    end
  end
end

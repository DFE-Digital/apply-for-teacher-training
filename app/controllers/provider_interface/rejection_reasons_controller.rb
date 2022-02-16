module ProviderInterface
  class RejectionReasonsController < ProviderInterfaceController
    before_action :set_application_choice

    def edit
      @wizard = RejectionReasonsWizard.new(store, current_step: 'edit')
      @wizard.save_state!
    end

    def store
      key = "rejection_reasons_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
      WizardStateStores::RedisStore.new(key: key)
    end
  end
end

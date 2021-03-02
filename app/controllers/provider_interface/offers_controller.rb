module ProviderInterface
  class OffersController < ProviderInterfaceController
    before_action :set_application_choice

    def create; end

  private

    def offer_store
      key = "offer_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
      WizardStateStores::RedisStore.new(key: key)
    end
  end
end

module ProviderInterface
  class RejectionReasonsController < ProviderInterfaceController
    before_action :set_application_choice

    def edit
      @wizard = wizard_class.new(store, current_step: 'edit')
      @wizard.save_state!
    end

    def update
      @wizard = wizard_class.new(store, rejection_reasons_params.merge(current_step: 'edit'))

      if @wizard.valid_for_current_step?
        @wizard.save_state!
        redirect_to action: @wizard.next_step
      else
        track_validation_error(@wizard)
        render :edit
      end
    end

    def check
      @wizard = wizard_class.new(store, current_step: 'check')
    end

    def store
      key = "rejection_reasons_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
      WizardStateStores::RedisStore.new(key: key)
    end

    def rejection_reasons_params
      params.require(:rejection_reasons).permit(*wizard_class.attribute_names, array_attribute_params)
    end

    def array_attribute_params
      wizard_class.array_attribute_names.index_with { |_| [] }
    end

    def wizard_class
      RejectionReasonsWizard
    end
  end
end

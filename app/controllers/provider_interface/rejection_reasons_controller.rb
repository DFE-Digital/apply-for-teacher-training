module ProviderInterface
  class RejectionReasonsController < ProviderInterfaceController
    before_action :set_application_choice
    before_action :check_application_is_rejectable

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
      params.require(:provider_interface_rejection_reasons_wizard).permit(*wizard_class.single_attribute_names, collection_attributes)
    end

    def collection_attributes
      wizard_class.collection_attribute_names.index_with { |_| [] }
    end

    def wizard_class
      ::ProviderInterface::RejectionReasonsWizard
    end

  private

    def check_application_is_rejectable
      return if ApplicationStateChange.new(@application_choice).can_reject?
      return if @application_choice.rejected_by_default?

      render_404
    end
  end
end

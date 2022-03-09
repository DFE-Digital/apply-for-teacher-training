module ProviderInterface
  class RejectionsController < ProviderInterfaceController
    before_action :check_feature_flag
    before_action :set_application_choice
    before_action :check_application_is_rejectable

    def new
      @wizard = wizard_class.new(store, current_step: 'new')
      @wizard.save_state!
    end

    def create
      @wizard = wizard_class.new(store, rejection_reasons_params.merge(current_step: 'new'))

      if @wizard.valid_for_current_step?
        @wizard.save_state!
        redirect_to action: @wizard.next_step
      else
        track_validation_error(@wizard)
        render :new
      end
    end

    def check
      @wizard = wizard_class.new(store, current_step: 'check')
    end

    def store
      key = "rejections_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
      WizardStateStores::RedisStore.new(key: key)
    end

    def rejection_reasons_params
      params.require(:provider_interface_rejections_wizard).permit(*wizard_class.single_attribute_names, collection_attributes)
    end

    def collection_attributes
      wizard_class.collection_attribute_names.index_with { |_| [] }
    end

    def wizard_class
      ::ProviderInterface::RejectionsWizard
    end

  private

    def check_application_is_rejectable
      return if ApplicationStateChange.new(@application_choice).can_reject?
      return if @application_choice.rejected_by_default?

      render_404
    end

    def check_feature_flag
      render_404 unless FeatureFlag.active?(:structured_reasons_for_rejection_redesign)
    end
  end
end

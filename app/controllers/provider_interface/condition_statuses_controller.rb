module ProviderInterface
  class ConditionStatusesController < ProviderInterfaceController
    include ClearWizardCache

    before_action :set_application_choice
    before_action :redirect_unless_application_pending_conditions
    before_action :requires_make_decisions_permission

    def edit
      clear_wizard_if_new_entry(ConfirmConditionsWizard.new(condition_statuses_store, {}))

      @form_object = ConfirmConditionsWizard.new(condition_statuses_store, offer: @application_choice.offer)
      @form_object.save_state!
    end

    def update
      @form_object = ConfirmConditionsWizard.new(condition_statuses_store, offer: @application_choice.offer)

      if @form_object.valid?
        handle_individual_status_transitions
        flash[:success] = success_message

        redirect_to provider_interface_application_choice_path(@application_choice)
      else
        track_validation_error(@form_object)
        redirect_to action: :edit
      end
    end

  private

    def redirect_unless_application_pending_conditions
      return if @application_choice.pending_conditions? || RecruitedWithPendingConditions.new(application_choice: @application_choice).call

      flash[:warning] = I18n.t('activerecord.errors.models.application_choice.attributes.status.invalid_transition')
      redirect_to provider_interface_application_choice_path(@application_choice)
    end

    def attributes_for_wizard
      condition_statuses_params.merge(offer: @application_choice.offer)
    end

    def condition_statuses_params
      params
        .expect(provider_interface_confirm_conditions_wizard: [statuses: {}])
    end

    def condition_statuses_store
      key = "condition_statuses_store_#{current_provider_user.id}_#{@application_choice.id}"
      WizardStateStores::RedisStore.new(key:)
    end

    def handle_individual_status_transitions
      ProviderInterface::SaveConditionStatuses.new(
        actor: current_provider_user,
        application_choice: @application_choice,
        statuses_form_object: @form_object,
      ).save!
    end

    def success_message
      if @form_object.all_conditions_met?
        'Conditions marked as met'
      elsif @form_object.any_condition_not_met?
        'Conditions marked as not met'
      else
        'Status of conditions updated'
      end
    end

    def wizard_controller_excluded_paths
      []
    end

    def wizard_flow_controllers
      ['provider_interface/condition_statuses', 'provider_interface/condition_statuses/checks'].freeze
    end
  end
end

module ProviderInterface
  class ReconfirmDeferredOffersController < ProviderInterfaceController
    before_action :find_application_choice
    before_action :update_wizard
    before_action :validate_wizard

    def start; end

    def conditions; end

    def update_conditions
      @wizard.save_state!
      redirect_to next_path
    end

    def check
      @wizard.course_option_id = @application_choice.offered_option.in_next_cycle&.id
    end

    def commit
      service_class = if @wizard.conditions_met?
                        ReinstateConditionsMet
                      else
                        ReinstatePendingConditions
                      end

      service = service_class.new(
        actor: current_provider_user,
        application_choice: @application_choice,
        course_option_id: @wizard.course_option_id,
      )

      if service.save
        @wizard.clear_state!
        flash[:success] = 'Deferred offer successfully confirmed for current cycle'
        redirect_to provider_interface_application_choice_path(@application_choice.id)
      else
        step, _id = @wizard.previous_step
        @wizard.errors.add(
          :base,
          'Unable to confirm offer, please try again. If problems persist please contact support',
        )
        render action: step
      end
    end

    def next_path
      step, _id = @wizard.next_step

      if step
        { action: step }
      else
        provider_interface_application_choice_path(@application_choice.id)
      end
    end

    def previous_path
      step, _id = @wizard.previous_step

      if step
        { action: step }
      else
        provider_interface_application_choice_path(@application_choice.id)
      end
    end

    helper_method :next_path, :previous_path

  private

    def find_application_choice
      @application_choice = ApplicationChoice.find(params[:application_choice_id])
    end

    def update_wizard
      @wizard = wizard_with new_data: reconfirm_deferred_offer_params.to_h
    end

    def validate_wizard
      unless @wizard.valid?
        step, _id = @wizard.previous_step

        if @wizard.errors.none?(:application_choice_id) && step
          render action: step and return
        else
          redirect_to provider_interface_application_choice_path(@application_choice.id) and return
        end
      end
    end

    def reconfirm_deferred_offer_params
      return {} unless params.key?(:provider_interface_reconfirm_deferred_offer_wizard)

      params.require(:provider_interface_reconfirm_deferred_offer_wizard)
        .permit(:conditions_status, :course_option_id)
    end

    def wizard_with(new_data: {})
      ReconfirmDeferredOfferWizard.new(
        WizardStateStores::SessionStore.new(session: session, key: persistence_key_for_wizard),
        new_data.merge(
          application_choice_id: @application_choice.id,
          current_step: action_name.to_s,
        ),
      )
    end

    def persistence_key_for_wizard
      "reconfirm_deferred_offer-#{current_provider_user.id}-#{@application_choice.id}"
    end
  end
end

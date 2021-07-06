module ProviderInterface
  class ReconfirmDeferredOffersController < ProviderInterfaceController
    before_action :set_application_choice
    before_action :require_deferred_offer_from_previous_cycle

    def start
      @wizard = wizard_for_step
    end

    def conditions
      @wizard = wizard_for_step
    end

    def update_conditions
      @wizard = wizard_for_step('conditions')
      if @wizard.valid?
        @wizard.save_state!
        redirect_to next_path
      else
        render :conditions
      end
    end

    def check
      @wizard = wizard_for_step
      @wizard.course_option_id = @application_choice.current_course_option.in_next_cycle&.id
    end

    def commit
      @wizard = wizard_for_step('check')

      render :check and return unless @wizard.valid?

      service_class = if @wizard.conditions_met?
                        ReinstateConditionsMet
                      else
                        ReinstatePendingConditions
                      end

      service = service_class.new(
        actor: current_provider_user,
        application_choice: @application_choice,
        course_option: @wizard.course_option,
      )

      if service.save
        @wizard.clear_state!
        flash[:success] = 'Deferred offer successfully confirmed for current cycle'
        redirect_to next_path
      else
        render :check
      end
    end

    # used within the controller, when redirecting after a write
    def next_path
      step = @wizard.next_step

      if step
        { action: step }
      else
        provider_interface_application_choice_path(@application_choice.id)
      end
    end

    # used within the controller, when redirecting after a write
    def previous_path
      step = @wizard.previous_step

      if step
        { action: step }
      else
        provider_interface_application_choice_path(@application_choice.id)
      end
    end

    helper_method :previous_path

  private

    def require_deferred_offer_from_previous_cycle
      unless @application_choice.status == 'offer_deferred' &&
             @application_choice.recruitment_cycle == RecruitmentCycle.previous_year
        redirect_to provider_interface_application_choice_path(@application_choice.id) and return
      end
    end

    def reconfirm_deferred_offer_params
      return {} unless params.key?(:provider_interface_reconfirm_deferred_offer_wizard)

      params.require(:provider_interface_reconfirm_deferred_offer_wizard)
        .permit(:conditions_status, :course_option_id)
    end

    def wizard_for_step(step = nil)
      step ||= action_name.to_s

      ReconfirmDeferredOfferWizard.new(
        WizardStateStores::SessionStore.new(session: session, key: persistence_key_for_wizard),
        reconfirm_deferred_offer_params.to_h.merge(
          application_choice_id: @application_choice.id,
          current_step: step,
        ),
      )
    end

    def persistence_key_for_wizard
      "reconfirm_deferred_offer-#{current_provider_user.id}-#{@application_choice.id}"
    end
  end
end

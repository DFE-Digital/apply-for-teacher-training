module ProviderInterface
  class ReconfirmDeferredOffersController < ProviderInterfaceController
    include ClearWizardCache

    before_action :set_application_choice
    before_action :require_deferred_offer_from_previous_cycle

    def new
      clear_wizard_if_new_entry(ReconfirmDeferredOfferWizard.new(deferred_offer_store, {}))

      @wizard = wizard_for_step
    end

    def conditions
      @wizard = wizard_for_step
    end

    def update_conditions
      @wizard = wizard_for_step('conditions')
      if @wizard.valid_for_current_step?
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

      render :check and return unless @wizard.valid_for_current_step?

      if ConfirmDeferredOffer.new(actor: current_provider_user,
                                  application_choice: @application_choice,
                                  course_option: @wizard.course_option,
                                  conditions_met: @wizard.conditions_met?).save
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
        provider_interface_application_choice_path(@application_choice)
      end
    end

    # used within the controller, when redirecting after a write
    def previous_path
      step = @wizard.previous_step

      if step
        { action: step }
      else
        provider_interface_application_choice_path(@application_choice)
      end
    end

    helper_method :previous_path

  private

    def require_deferred_offer_from_previous_cycle
      unless @application_choice.status == 'offer_deferred' &&
             @application_choice.recruitment_cycle == current_timetable.relative_previous_year
        redirect_to provider_interface_application_choice_path(@application_choice.id) and return
      end
    end

    def reconfirm_deferred_offer_params
      return {} unless params.key?(:provider_interface_reconfirm_deferred_offer_wizard)

      params
            .expect(provider_interface_reconfirm_deferred_offer_wizard: %i[conditions_status course_option_id])
    end

    def wizard_for_step(step = nil)
      step ||= action_name.to_s

      ReconfirmDeferredOfferWizard.new(deferred_offer_store,
                                       reconfirm_deferred_offer_params.to_h.merge(form_context_params(step)))
    end

    def form_context_params(step)
      {
        application_choice_id: @application_choice.id,
        current_step: step,
      }
    end

    def deferred_offer_store
      key = "reconfirm_deferred_offer-#{current_provider_user.id}-#{@application_choice.id}"
      WizardStateStores::SessionStore.new(session:, key:)
    end

    def wizard_flow_controllers
      ['provider_interface/reconfirm_deferred_offers'].freeze
    end

    def wizard_controller_excluded_paths
      []
    end
  end
end

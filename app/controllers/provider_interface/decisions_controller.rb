module ProviderInterface
  class DecisionsController < ProviderInterfaceController
    before_action :set_application_choice
    before_action :confirm_application_is_in_decision_pending_state, only: %i[new create]
    before_action :requires_make_decisions_permission

    def new
      @wizard = OfferWizard.build_from_application_choice(
        offer_store,
        @application_choice,
        provider_user_id: current_provider_user.id,
        current_step: 'select_option',
        decision: :default,
        action: action,
      )
      @wizard.save_state!
    end

    def create
      @wizard = OfferWizard.new(offer_store, { decision: selected_decision, current_step: 'select_option' })

      if @wizard.valid_for_current_step?

        @wizard.save_state!

        if @wizard.decision == 'rejection'
          redirect_to provider_interface_reasons_for_rejection_initial_questions_path(@application_choice)
        else
          redirect_to [:new, :provider_interface, @application_choice, :offer, @wizard.next_step]
        end
      else
        track_validation_error(@wizard)
        render 'new'
      end
    end

    def new_withdraw_offer
      @withdraw_offer = WithdrawOffer.new(
        actor: current_provider_user,
        application_choice: @application_choice,
      )
    end

    def confirm_withdraw_offer
      @withdraw_offer = WithdrawOffer.new(
        actor: current_provider_user,
        application_choice: @application_choice,
        offer_withdrawal_reason: params.dig(:withdraw_offer, :offer_withdrawal_reason),
      )
      if !@withdraw_offer.valid?
        track_validation_error(@withdraw_offer)
        render action: :new_withdraw_offer
      end
    end

    def withdraw_offer
      @withdraw_offer = WithdrawOffer.new(
        actor: current_provider_user,
        application_choice: @application_choice,
        offer_withdrawal_reason: params.dig(:withdraw_offer, :offer_withdrawal_reason),
      )
      if @withdraw_offer.save
        flash[:success] = 'Offer successfully withdrawn'
        redirect_to provider_interface_application_choice_feedback_path(
          application_choice_id: @application_choice.id,
        )
      else
        track_validation_error(@withdraw_offer)
        render action: :new_withdraw_offer
      end
    end

    def new_defer_offer
      @defer_offer = DeferOffer.new(
        actor: current_provider_user,
        application_choice: @application_choice,
      )
    end

    def defer_offer
      DeferOffer.new(
        actor: current_provider_user,
        application_choice: @application_choice,
      ).save!

      flash[:success] = 'Offer deferred'
      redirect_to provider_interface_application_choice_offer_path(@application_choice)
    end

  private

    def make_an_offer_params
      params.require(:make_an_offer)
    end

    def confirm_application_is_in_decision_pending_state
      return if @application_choice.decision_pending?

      redirect_to(provider_interface_application_choice_path(@application_choice))
    end

    def provider_interface_offer_params
      params[:provider_interface_offer_wizard] || ActionController::Parameters.new
    end

    def selected_decision
      provider_interface_offer_params.permit(:decision)[:decision]
    end

    def offer_store
      key = "offer_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
      WizardStateStores::RedisStore.new(key: key)
    end

    def action
      'back' if !!params[:back]
    end
  end
end

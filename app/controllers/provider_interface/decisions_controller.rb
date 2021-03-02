module ProviderInterface
  class DecisionsController < ProviderInterfaceController
    before_action :set_application_choice
    before_action :requires_make_decisions_permission

    def new
      @wizard = OfferWizard.new(offer_store,
                                offer_context_params(@application_choice.course_option).merge!(current_step: 'select_option'))
      @wizard.save_state!
    end

    def create
      @wizard = OfferWizard.new(offer_store, { current_context: selected_decision })
      @wizard.save_state!

      if @wizard.current_context == 'rejection'
        @wizard.clear_state!

        redirect_to provider_interface_reasons_for_rejection_initial_questions_path(@application_choice)
      else
        redirect_to [:new, :provider_interface, @application_choice, :offer, @wizard.next_step]
      end
    end

    def respond
      if FeatureFlag.active?(:updated_offer_flow)
        redirect_to new_provider_interface_application_choice_decision_path(@application_choice) and return
      end

      @pick_response_form = PickResponseForm.new
      @alternative_study_mode = @application_choice.offered_option.alternative_study_mode
    end

    def submit_response
      @pick_response_form = PickResponseForm.new(decision: params.dig(:provider_interface_pick_response_form, :decision))
      if @pick_response_form.valid?
        redirect_to @pick_response_form.redirect_attrs
      else
        render action: :respond
      end
    end

    def new_offer
      course_option = if params[:course_option_id]
                        CourseOption.find(params[:course_option_id])
                      else
                        @application_choice.course_option
                      end

      @application_offer = MakeAnOffer.new(
        actor: current_provider_user,
        application_choice: @application_choice,
        course_option: course_option,
      )
    end

    def confirm_offer
      course_option = CourseOption.find(params[:course_option_id])

      @application_offer = MakeAnOffer.new(
        actor: current_provider_user,
        application_choice: @application_choice,
        course_option: course_option,
        standard_conditions: make_an_offer_params[:standard_conditions],
        further_conditions: make_an_offer_params.permit(
          :further_conditions0,
          :further_conditions1,
          :further_conditions2,
          :further_conditions3,
        ).to_h,
      )
      render action: :new_offer if !@application_offer.valid?
    end

    def create_offer
      course_option = CourseOption.find(params[:course_option_id])

      @application_offer = MakeAnOffer.new(
        actor: current_provider_user,
        application_choice: @application_choice,
        course_option: course_option,
        offer_conditions: params.dig(:offer_conditions),
      )

      if @application_offer.save
        flash[:success] = 'Offer successfully made to candidate'
        redirect_to provider_interface_application_choice_path(
          application_choice_id: @application_choice.id,
        )
      else
        render action: :new_offer
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

      flash[:success] = 'Offer successfully deferred'
      redirect_to provider_interface_application_choice_offer_path(@application_choice)
    end

  private

    def make_an_offer_params
      params.require(:make_an_offer)
    end

    def offer_context_params(course_option)
      {
        course_id: course_option.course.id,
        course_option_id: course_option.id,
        provider_id: course_option.provider.id,
        study_mode: course_option.study_mode,
        location_id: course_option.site.id,
        current_context: :default,
        standard_conditions: MakeAnOffer::STANDARD_CONDITIONS,
      }
    end

    def selected_decision
      params.require(:provider_interface_offer_wizard).permit(:decision)[:decision]
    end

    def offer_store
      key = "offer_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
      WizardStateStores::RedisStore.new(key: key)
    end
  end
end

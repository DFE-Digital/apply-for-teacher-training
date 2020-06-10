module ProviderInterface
  class DecisionsController < ProviderInterfaceController
    before_action :set_application_choice
    before_action :requires_provider_user_make_decisions_permission
    before_action :requires_provider_change_response_feature_flag, only: %i[new_withdraw_offer confirm_withdraw_offer withdraw_offer]

    def respond
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
      offer_conditions_array = JSON.parse(params.dig(:offer_conditions))
      course_option = CourseOption.find(params[:course_option_id])

      @application_offer = MakeAnOffer.new(
        actor: current_provider_user,
        application_choice: @application_choice,
        course_option: course_option,
        offer_conditions: offer_conditions_array,
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

    def new_reject
      @reject_application = RejectApplication.new(application_choice: @application_choice)
    end

    def confirm_reject
      @reject_application = RejectApplication.new(
        application_choice: @application_choice,
        rejection_reason: params.dig(:reject_application, :rejection_reason),
      )
      render action: :new_reject if !@reject_application.valid?
    end

    def create_reject
      @reject_application = RejectApplication.new(
        application_choice: @application_choice,
        rejection_reason: params.dig(:reject_application, :rejection_reason),
      )
      if @reject_application.save
        flash[:success] = 'Application successfully rejected'
        redirect_to provider_interface_application_choice_path(
          application_choice_id: @application_choice.id,
        )
      else
        render action: :new_reject
      end
    end

    def new_withdraw_offer
      @withdraw_offer = WithdrawOffer.new(
        application_choice: @application_choice,
      )
    end

    def confirm_withdraw_offer
      @withdraw_offer = WithdrawOffer.new(
        application_choice: @application_choice,
        offer_withdrawal_reason: params.dig(:withdraw_offer, :offer_withdrawal_reason),
      )
      if !@withdraw_offer.valid?
        render action: :new_withdraw_offer
      end
    end

    def withdraw_offer
      @withdraw_offer = WithdrawOffer.new(
        application_choice: @application_choice,
        offer_withdrawal_reason: params.dig(:withdraw_offer, :offer_withdrawal_reason),
      )
      if @withdraw_offer.save
        flash[:success] = 'Offer successfully withdrawn'
        redirect_to provider_interface_application_choice_path(
          application_choice_id: @application_choice.id,
        )
      else
        render action: :new_withdraw_offer
      end
    end

  private

    def requires_provider_change_response_feature_flag
      render_404 unless FeatureFlag.active?('provider_change_response')
    end

    def requires_provider_user_make_decisions_permission
      provider = @application_choice.offered_course.provider

      if FeatureFlag.active?('provider_make_decisions_restriction') &&
          !current_provider_user.can_make_decisions_for?(provider)

        redirect_to provider_interface_missing_permission_path(
          provider_id: provider.id,
          provider_user_id: current_provider_user.id,
          permission: 'make_decisions',
        )
      end
    end

    def set_application_choice
      @application_choice = GetApplicationChoicesForProviders.call(providers: current_provider_user.providers)
        .find(params[:application_choice_id])
    end

    def make_an_offer_params
      params.require(:make_an_offer)
    end
  end
end

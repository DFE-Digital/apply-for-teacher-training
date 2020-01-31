module ProviderInterface
  class DecisionsController < ProviderInterfaceController
    before_action :set_application_choice

    def respond
      @pick_response_form = PickResponseForm.new
    end

    def submit_response
      @pick_response_form = PickResponseForm.new(decision: params.dig(:provider_interface_pick_response_form, :decision))
      render action: :respond if !@pick_response_form.valid?

      if @pick_response_form.decision == 'offer'
        redirect_to action: :new_offer
      elsif @pick_response_form.decision == 'reject'
        redirect_to action: :new_reject
      end
    end

    def new_offer
      @application_offer = MakeAnOffer.new(application_choice: @application_choice)
    end

    def confirm_offer
      @application_offer = MakeAnOffer.new(
        application_choice: @application_choice,
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

      @application_offer = MakeAnOffer.new(
        application_choice: @application_choice,
        offer_conditions: offer_conditions_array,
      )

      if @application_offer.save
        flash[:success] = 'Application status changed to ‘Offer made’'
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
        flash[:success] = 'Application status changed to ‘Rejected’'
        redirect_to provider_interface_application_choice_path(
          application_choice_id: @application_choice.id,
        )
      else
        render action: :new_reject
      end
    end

    def new_edit_response
      @edit_response = EditResponseForm.new
    end

  private

    def set_application_choice
      @application_choice = GetApplicationChoicesForProviders.call(providers: current_provider_user.providers)
        .find(params[:application_choice_id])
    end

    def make_an_offer_params
      params.require(:make_an_offer)
    end
  end
end

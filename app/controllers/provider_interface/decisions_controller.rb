module ProviderInterface
  class DecisionsController < ProviderInterfaceController
    before_action :set_application_choice_and_presenter

    def respond; end

    def submit_response
      decision = params[:application_choice][:decision] if params[:application_choice]
      if decision == 'offer'
        redirect_to action: :new_offer
      elsif decision == 'reject'
        redirect_to action: :new_reject
      end
    end

    def new_offer
      @application_offer = MakeAnOffer.new(application_choice: @application_choice)
    end

    def confirm_offer
      offer_conditions = [
        make_an_offer_params[:standard_conditions],
        make_an_offer_params[:further_conditions],
      ].flatten.reject(&:blank?)
      @application_offer = MakeAnOffer.new(
        application_choice: @application_choice,
        offer_conditions: offer_conditions,
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
        flash[:success] = 'Application status changed to ‘Offer Made’'
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

  private

    def set_application_choice_and_presenter
      @application_choice = GetApplicationChoicesForProvider.call(provider: current_provider_user.provider)
        .find(params[:application_choice_id])

      @presenter = ApplicationChoicePresenter.new(@application_choice)
    end

    def make_an_offer_params
      params.require(:make_an_offer)
    end
  end
end

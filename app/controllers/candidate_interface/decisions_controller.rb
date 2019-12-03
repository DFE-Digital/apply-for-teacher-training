module CandidateInterface
  class DecisionsController < CandidateInterfaceController
    before_action :set_application_choice

    def offer
      if FeatureFlag.active?('accept_and_decline_via_ui')
        @respond_to_offer = CandidateInterface::RespondToOfferForm.new
      else
        render :offer_via_support
      end
    end

    def respond_to_offer
      response = params.dig(:candidate_interface_respond_to_offer_form, :response)

      @respond_to_offer = CandidateInterface::RespondToOfferForm.new(response: response)

      if !@respond_to_offer.valid?
        render :offer
      elsif @respond_to_offer.decline?
        redirect_to candidate_interface_decline_offer_path(@application_choice)
      elsif @respond_to_offer.accept?
        redirect_to candidate_interface_accept_offer_path(@application_choice)
      end
    end

    def decline; end

    def confirm_decline
      decline = DeclineOffer.new(application_choice: @application_choice.reload)
      decline.save!
      redirect_to candidate_interface_application_complete_path
    end

    def accept; end

    def confirm_accept
      accept = AcceptOffer.new(application_choice: @application_choice.reload)
      accept.save!
      redirect_to candidate_interface_application_complete_path
    end

    def withdraw; end

    def confirm_withdraw
      raise unless FeatureFlag.active?('candidate_withdrawals')

      flash[:success] = 'Your application has been withdrawn'
      redirect_to candidate_interface_application_form_path
    end

  private

    def set_application_choice
      @application_choice = current_candidate.current_application.application_choices.find(params[:id])
    end
  end
end

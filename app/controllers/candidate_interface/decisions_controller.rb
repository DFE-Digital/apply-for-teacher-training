module CandidateInterface
  class DecisionsController < CandidateInterfaceController
    before_action :set_application_choice
    before_action :check_that_candidate_can_decline, only: %i[decline_offer confirm_decline]
    before_action :check_that_candidate_can_accept, only: %i[accept_offer confirm_accept]
    before_action :check_that_candidate_can_withdraw, only: %i[withdraw confirm_withdraw]
    before_action :check_that_candidate_has_an_offer, only: %i[offer respond_to_offer]

    def offer
      @respond_to_offer = CandidateInterface::RespondToOfferForm.new
      @offer_count = @application_choice.self_and_siblings.offer.count
    end

    def respond_to_offer
      response = params.dig(:candidate_interface_respond_to_offer_form, :response)

      @respond_to_offer = CandidateInterface::RespondToOfferForm.new(response: response)

      if !@respond_to_offer.valid?
        @offer_count = @application_choice.self_and_siblings.offer.count
        render :offer
      elsif @respond_to_offer.decline?
        redirect_to candidate_interface_decline_offer_path(@application_choice)
      elsif @respond_to_offer.accept?
        redirect_to candidate_interface_accept_offer_path(@application_choice)
      end
    end

    def decline_offer; end

    def confirm_decline
      decline = DeclineOffer.new(application_choice: @application_choice.reload)
      decline.save!
      flash[:success] = "You have declined your offer for #{@application_choice.course.name_and_code} at #{@application_choice.provider.name}"
      redirect_to candidate_interface_application_complete_path
    end

    def accept_offer; end

    def confirm_accept
      accept = AcceptOffer.new(application_choice: @application_choice.reload)
      accept.save!
      flash[:success] = "You have accepted your offer for #{@application_choice.course.name_and_code} at #{@application_choice.provider.name}"
      redirect_to candidate_interface_application_complete_path
    end

    def withdraw; end

    def confirm_withdraw
      withdrawal = WithdrawApplication.new(application_choice: @application_choice)
      withdrawal.save!

      redirect_to candidate_interface_withdrawal_feedback_path
    end

    def withdrawal_feedback
      @withdrawal_feedback_form = WithdrawalFeedbackForm.new
      @provider = @application_choice.provider
      @course = @application_choice.course
    end

    def confirm_withdrawal_feedback
      @withdrawal_feedback_form = WithdrawalFeedbackForm.new(withdrawl_feedback_params)

      if @withdrawal_feedback_form.save(@application_choice)
        flash[:success] = I18n.t('decisions.withdrawal_feedback.success.flash')

        redirect_to candidate_interface_application_complete_path
      else
        track_validation_error(@withdrawal_feedback_form)
        @provider = @application_choice.provider
        @course = @application_choice.course

        render :withdrawal_feedback
      end
    end

  private

    def set_application_choice
      @application_choice = @current_application.application_choices.find(params[:id])
    end

    def single_application_choice?
      @current_application.application_choices.size == 1
    end
    helper_method :single_application_choice?

    def check_that_candidate_can_decline
      unless ApplicationStateChange.new(@application_choice).can_decline?
        render_404
      end
    end

    def check_that_candidate_can_accept
      unless ApplicationStateChange.new(@application_choice).can_accept?
        render_404
      end
    end

    def check_that_candidate_can_withdraw
      unless ApplicationStateChange.new(@application_choice).can_withdraw?
        render_404
      end
    end

    def check_that_candidate_has_an_offer
      render_404 unless @application_choice.offer?
    end

    def withdrawl_feedback_params
      params.fetch(:candidate_interface_withdrawal_feedback_form, {}).permit(:feedback, :explanation, :consent_to_be_contacted, :contact_details)
    end

    def course_choice_rows
      [
        {
          key: 'Provider',
          value: @application_choice.current_course.provider.name,
        },
        {
          key: 'Course',
          value: @application_choice.current_course.name_and_code,
        },
        {
          key: 'Location',
          value: @application_choice.current_course_option.site.name,
        },
      ]
    end
    helper_method :course_choice_rows
  end
end

module CandidateInterface
  class AccountRecoveryController < CandidateInterfaceController
    before_action :check_if_user_can_recover
    before_action :check_if_user_has_account_recovery_request

    def new
      @account_recovery = CandidateInterface::AccountRecoveryForm.new(current_candidate:)
    end

    def create
      @account_recovery = CandidateInterface::AccountRecoveryForm.new(
        current_candidate:,
        code: permitted_params[:code],
      )

      if @account_recovery.call
        terminate_session
        start_new_session_for(
          candidate: @account_recovery.old_candidate,
          id_token_hint: @account_recovery.id_token_hint,
        )

        flash[:success] = I18n.t('.authentication.successful_account_recovery_html')
        redirect_to candidate_interface_interstitial_path
      else
        render :new
      end
    end

  private

    def permitted_params
      strip_whitespace(
        params.expect(candidate_interface_account_recovery_form: [:code]),
      )
    end

    def check_if_user_can_recover
      redirect_to candidate_interface_details_path unless current_candidate.recoverable?
    end

    def check_if_user_has_account_recovery_request
      redirect_to candidate_interface_details_path if current_candidate.account_recovery_request.nil?
    end
  end
end

module CandidateInterface
  class AccountRecoveryRequestsController < CandidateInterfaceController
    before_action :check_if_user_can_recover

    def new
      @account_recovery_request = CandidateInterface::AccountRecoveryRequestForm
        .build_from_candidate(current_candidate)
    end

    def create
      @account_recovery_request = CandidateInterface::AccountRecoveryRequestForm.new(
        current_candidate:,
        previous_account_email_address: permitted_params[:previous_account_email_address],
      )

      if @account_recovery_request.save_and_email_candidate
        redirect_to candidate_interface_account_recovery_new_path
      else
        render :new
      end
    end

  private

    def permitted_params
      strip_whitespace(
        params.require(:candidate_interface_account_recovery_request_form).permit(
          :previous_account_email_address,
        ),
      )
    end

    def check_if_user_can_recover
      redirect_to candidate_interface_details_path unless current_candidate.recoverable?
    end
  end
end

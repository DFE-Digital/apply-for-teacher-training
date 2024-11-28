module CandidateInterface
  class AccountRecoveryRequestsController < CandidateInterfaceController
    #### Block requests if current candidate has account_recover successful
    def new
      @account_recovery_request = CandidateInterface::AccountRecoveryRequestForm.new(
        current_candidate:,
      )
    end

    def create
      @account_recovery_request = CandidateInterface::AccountRecoveryRequestForm.new(
        current_candidate:,
        previous_account_email: permitted_params[:previous_account_email],
      )

      if @account_recovery_request.save
        # send email if we find a candidate with previous_account_email
        redirect_to candidate_interface_account_recovery_new_path
        #redirect_to generic message saying we have sent email
      else
        render :new
      end
    end

  private

    def permitted_params
      strip_whitespace(
        params.require(:candidate_interface_account_recovery_request_form).permit(:previous_account_email),
      )
    end
  end
end

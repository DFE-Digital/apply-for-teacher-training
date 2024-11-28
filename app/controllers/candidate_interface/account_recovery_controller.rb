module CandidateInterface
  class AccountRecoveryController < CandidateInterfaceController
    def new
      @account_recovery = CandidateInterface::AccountRecoveryForm.new(current_candidate:)
    end

    ### Background logout for one login
    ### If the user logs out of one login will they be logged out of apply?

    def create
      @account_recovery = CandidateInterface::AccountRecoveryForm.new(
        current_candidate:,
        code: permitted_params[:code],
      )

      if @account_recovery.call
        sign_in(@account_recovery.old_candidate, scope: :candidate)
        redirect_to root_path
      else
        render :new
      end
    end

  private

    def permitted_params
      params.require(:candidate_interface_account_recovery_form).permit(:code)
    end
  end
end

module CandidateInterface
  class AccountRecoveryController < CandidateInterfaceController
    #### Block requests if current candidate has account_recover successful
    def new
      @account_recovery = CandidateInterface::AccountRecoveryForm.new(current_candidate:)
    end

    ### Background logout for one login
    ### If the user logs out of one login will they be logged out of apply?

    ### To do:
    ### Create generic 'We have sent an email' page after recover request
    ### Back links?
    ### Fix the account_recovery_request error
    ### Raise exceptions rather than errors in one login auth service
    ### Send emails
    ### Test?
    ### Cleanup?
    ### Deploy to review

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
      strip_whitespace(
        params.require(:candidate_interface_account_recovery_form).permit(:code),
      )
    end
  end
end

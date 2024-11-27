module CandidateInterface
  class AccountRecoveryController < CandidateInterfaceController
    before_action :check_if_user_recovered

    def new
      @account_recovery = CandidateInterface::AccountRecoveryForm.new(current_candidate:)
    end

    ### Background logout for one login
    ### If the user logs out of one login will they be logged out of apply?

    ### To do:
    ### Deploy to review
    ### Setup review env with one login keys
    ### Setup review env test notify key
    ### Do we need to setup accounts for people on review?

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

    def check_if_user_recovered
      redirect_to candidate_interface_details_path if current_candidate.recovered?
    end
  end
end

module CandidateInterface
  class AccountRecoveryRequestsController < ApplicationController
    #### Block requests if current candidate has account_recover successful
    def new
      @account_recovery_request = AccountRecoveryRequest.new
    end

    def create
      @account_recovery_request = current_candidate.build_account_recovery_request(
        previous_account_email: permitted_params[:previous_account_email],
        code: AccountRecoveryRequest.generate_code,
      )

      if @account_recovery_request.save
        # send email if we find a candidate with previous_account_email
        redirect_to candidate_interface_account_recovery_new_path
      else
        render :new
      end
    end

  private

    def permitted_params
      params.require(:account_recovery_request).permit(:previous_account_email)
    end
  end
end

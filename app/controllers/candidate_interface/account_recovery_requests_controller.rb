module CandidateInterface
  class AccountRecoveryRequestsController < CandidateInterfaceController
    before_action :check_if_user_recovered

    def new
      @account_recovery_request = CandidateInterface::AccountRecoveryRequestForm
        .build_from_candidate(current_candidate)
    end

    def create
      @account_recovery_request = CandidateInterface::AccountRecoveryRequestForm.new(
        current_candidate:,
        previous_account_email: permitted_params[:previous_account_email],
      )

      if @account_recovery_request.save
        if permitted_params[:resend_pressed]
          flash[:success] = "A new code has been sent to #{permitted_params[:previous_account_email]}"
          redirect_path = candidate_interface_account_recovery_new_path
        else
          redirect_path = candidate_interface_account_recovery_requests_confirm_path
        end

        redirect_to redirect_path
      else
        render :new
      end
    end

    def confirm; end

  private

    def permitted_params
      strip_whitespace(
        params.require(:candidate_interface_account_recovery_request_form).permit(
          :previous_account_email,
          :resend_pressed,
        ),
      )
    end

    def check_if_user_recovered
      redirect_to candidate_interface_details_path if current_candidate.recovered?
    end
  end
end

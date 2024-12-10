module CandidateInterface
  class WithdrawalReasonsController < CandidateInterfaceController
    before_action :set_application_choice
    before_action :check_that_candidate_can_withdraw

    def new
      @withdrawal_reason_form = WithdrawalReasonsForm.new
    end

    def create; end

    def continue
      @withdrawal_reason_form = WithdrawalReasonsForm.new(withdrawal_reasons_params)
      if @withdrawal_reason_form.valid?
        redirect_to candidate_interface_withdrawal_reason_with_step_path(step_id: withdrawal_reasons_params[:reason])
      else
        render :new
      end
    end

    def withdrawal_reasons_params
      params.require(:candidate_interface_withdrawal_reasons_form).permit(:reason, :comment)
    end

  private

    def set_application_choice
      @application_choice = @current_application.application_choices.find(params[:id])
    end

    def check_that_candidate_can_withdraw
      unless ApplicationStateChange.new(@application_choice).can_withdraw?
        render_404
      end
    end
  end
end

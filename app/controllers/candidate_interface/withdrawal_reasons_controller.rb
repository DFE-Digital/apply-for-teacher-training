module CandidateInterface
  class WithdrawalReasonsController < CandidateInterfaceController
    before_action :set_application_choice
    before_action :check_that_candidate_can_withdraw

    def new
      @withdrawal_reason_form = WithdrawalReasonsForm.new(initial_params)
      @withdrawal_reason_form.reason_id
    end

    def create
      @withdrawal_reason_form = WithdrawalReasonsForm.new(withdrawal_reasons_params)
    end

    def continue
      @withdrawal_reason_form = WithdrawalReasonsForm.new(withdrawal_reasons_params)
      if @withdrawal_reason_form.valid?
        if @withdrawal_reason_form.saveable?
          'hellos'
        else
          redirect_to candidate_interface_withdrawal_reason_path(reason_id: withdrawal_reasons_params[:reason])
        end
      else
        render :new
      end
    end

  private

    def withdrawal_reasons_params
      params.require(:candidate_interface_withdrawal_reasons_form).permit(:reason, :comment)
    end

    def initial_params
      params.permit(:reason_id)
    end

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

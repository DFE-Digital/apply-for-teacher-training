module CandidateInterface
  class WithdrawalReasonsController < CandidateInterfaceController
    before_action :set_application_choice
    before_action :check_that_candidate_can_withdraw

    def new
      @withdrawal_reason_form = WithdrawalReasonsForm.new(initial_params)
    end

    def confirm
      @withdrawal_reason_form = WithdrawalReasonsForm.new(confirm_params)
    end

    def create
      WithdrawalReasonsForm.new(confirm_params, application_choice: @application_choice).save!
      flash[:success] = I18n.t(
        'candidate_interface.withdrawal_reasons.success_message',
        provider_name: @application_choice.current_course_option.provider.name,
      )
      redirect_to candidate_interface_application_choices_path
    end

    def continue
      @withdrawal_reason_form = WithdrawalReasonsForm.new(withdrawal_reasons_params)
      if @withdrawal_reason_form.valid?
        if @withdrawal_reason_form.saveable?
          redirect_to candidate_interface_withdrawal_reason_confirm_path(params: @withdrawal_reason_form.confirm_params)
        else
          redirect_to candidate_interface_withdrawal_reason_path(primary_reason_id: @withdrawal_reason_form.primary_reason)
        end
      else
        render :new
      end
    end

  private

    def confirm_params
      params.permit(:primary_reason, :primary_other_comment)
    end

    def withdrawal_reasons_params
      params.require(:candidate_interface_withdrawal_reasons_form).permit(:primary_reason, :primary_other_comment)
    end

    def initial_params
      params.permit(:primary_reason_id, :primary_other_comment)
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

module CandidateInterface
  module WithdrawalReasons
    class LevelTwoReasonsController < WithdrawalsController
      def show
        @level_one_reason = level_one_reason
      end

      def new
        @level_two_reasons_form = LevelTwoReasonsForm.build_from_application_choice(level_one_reason, @application_choice)
      end

      def create
        @level_two_reasons_form = LevelTwoReasonsForm.new(form_params, application_choice: @application_choice)
        if @level_two_reasons_form.valid?
          @level_two_reasons_form.persist!
          redirect_to candidate_interface_withdrawal_reasons_level_two_reasons_show_path
        else
          render :new
        end
      end

    private

      def form_params
        params.require(:candidate_interface_withdrawal_reasons_level_two_reasons_form)
              .permit(:comment, :personal_circumstances_reasons_comment, level_two_reasons: [], personal_circumstances_reasons: [])
              .merge({ level_one_reason: })
      end

      def level_one_reason
        params[:level_one_reason]
      end
    end
  end
end

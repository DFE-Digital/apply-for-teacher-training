module CandidateInterface
  module WithdrawalReasons
    class LevelTwoReasonsController < WithdrawalsController
      def start
        @level_two_reasons_form = LevelTwoReasonsForm.build_from_application_choice(level_one_reason, @application_choice)
      end

      def continue
        @level_two_reasons_form = LevelTwoReasonsForm.new(form_params, application_choice: @application_choice)
        if @level_two_reasons_form.valid?
          @level_two_reasons_form.persist!
          redirect_to candidate_interface_withdrawal_reasons_level_two_reasons_review_path
        else
          render :start
        end
      end

      def review
        @level_one_reason = level_one_reason
      end

      def cancel
        @application_choice.draft_withdrawal_reasons.each(&:destroy!)
        redirect_to candidate_interface_application_complete_path(@application_choice)
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

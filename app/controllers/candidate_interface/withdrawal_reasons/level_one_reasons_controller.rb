module CandidateInterface
  module WithdrawalReasons
    class LevelOneReasonsController < WithdrawalsController
      before_action :set_draft_reason, only: %i[show edit create]
      before_action :clear_earlier_drafts, only: %i[show]

      def show
        @level_one_reasons_form = LevelOneReasonsForm.build_from_reason(@level_one_reason)
      end

      def new
        @level_one_reasons_form = LevelOneReasonsForm.new({ level_one_reason: level_one_reason_params[:level_one_reason] })
      end

      def edit
        @level_one_reasons_form = LevelOneReasonsForm.build_from_reason(@level_one_reason)
      end

      def create
        attributes = @level_one_reason.present? ? form_params.merge(id: @level_one_reason.id) : form_params
        @level_one_reasons_form = LevelOneReasonsForm.new(attributes, application_choice: @application_choice)

        if @level_one_reasons_form.invalid?
          render :new
        elsif @level_one_reasons_form.ready_for_review?
          draft_withdrawal_reason = @level_one_reasons_form.persist!
          redirect_to candidate_interface_withdrawal_reasons_level_one_reason_show_path(
            withdrawal_reason_id: draft_withdrawal_reason.id,
          )
        else
          redirect_to candidate_interface_withdrawal_reasons_level_two_reasons_new_path(
            level_one_reason: @level_one_reasons_form.level_one_reason,
          )
        end
      end

    private

      def form_params
        params.expect(candidate_interface_withdrawal_reasons_level_one_reasons_form: %i[level_one_reason comment])
      end

      def set_draft_reason
        if withdrawal_reason_id.positive?
          @level_one_reason = @application_choice.draft_withdrawal_reasons.find(withdrawal_reason_id)
        end
      end

      def clear_earlier_drafts
        @application_choice.draft_withdrawal_reasons.where.not(id: withdrawal_reason_id).destroy_all
      end

      def withdrawal_reason_id
        params[:withdrawal_reason_id].to_i
      end

      def level_one_reason_params
        params.permit(:level_one_reason)
      end
    end
  end
end

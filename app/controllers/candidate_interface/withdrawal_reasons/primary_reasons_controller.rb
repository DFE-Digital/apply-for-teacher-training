module CandidateInterface
  module WithdrawalReasons
    class PrimaryReasonsController < WithdrawalReasonsController
      before_action :set_draft_reason, only: %i[review withdraw edit continue]
      before_action :clear_earlier_drafts, only: %i[review withdraw]
      def start
        @primary_reasons_form = PrimaryReasonsForm.new
      end

      def continue
        attributes = @primary_reason.present? ? form_params.merge(id: @primary_reason.id) : form_params
        @primary_reasons_form = PrimaryReasonsForm.new(attributes, application_choice: @application_choice)
        if @primary_reasons_form.invalid?
          render :start
        elsif @primary_reasons_form.can_save?
          draft_withdrawal_reason = @primary_reasons_form.save!
          redirect_to candidate_interface_withdrawal_reasons_primary_reason_review_path(withdrawal_reason_id: draft_withdrawal_reason.id)
        else
          redirect_to candidate_interface_withdrawal_reasons_secondary_reasons_start_path(
            primary_reason: @primary_reasons_form.primary_reason,
          )
        end
      end

      def review
        @primary_reasons_form = PrimaryReasonsForm.build_from_reason(@primary_reason)
      end

      def withdraw
        WithdrawApplication.new(application_choice: @application_choice).save!
        flash[:success] = I18n.t(
          'candidate_interface.withdrawal_reasons.success_message',
          provider_name: @application_choice.current_course_option.provider.name,
        )
        redirect_to candidate_interface_application_complete_path(@application_choice)
      end

      def edit
        @primary_reasons_form = PrimaryReasonsForm.build_from_reason(@primary_reason)
      end

    private

      def form_params
        params.require(:candidate_interface_withdrawal_reasons_primary_reasons_form).permit(:primary_reason, :comment)
      end

      def set_draft_reason
        if withdrawal_reason_id.positive?
          @primary_reason = @application_choice.draft_withdrawal_reasons.find(withdrawal_reason_id)
        end
      end

      def clear_earlier_drafts
        @application_choice.draft_withdrawal_reasons.where.not(id: withdrawal_reason_id).destroy_all
      end

      def withdrawal_reason_id
        params[:withdrawal_reason_id].to_i
      end
    end
  end
end

module SupportInterface
  class FraudAuditingMatchesController < SupportInterfaceController
    def index
      @matches = FraudMatch.where(recruitment_cycle_year: RecruitmentCycle.current_year).all.sort_by(&:created_at)
    end

    def fraudulent
      fraud_match = FraudMatch.find(params[:id])

      if fraud_match.fraudulent?
        fraud_match.update!(fraudulent: false)
        flash[:success] = 'Match marked as non fraudulent'
      else
        fraud_match.update!(fraudulent: true)
        flash[:success] = 'Match marked as fraudulent'
      end

      redirect_to support_interface_fraud_auditing_matches_path
    end

    def confirm_block_submission
      @candidate_to_block = BlockSubmissionForm.new
    end

    def block_submission
      @candidate_to_block = BlockSubmissionForm.new(block_submission_params)

      if @candidate_to_block.save(params[:fraud_match_id])
        flash[:success] = 'Candidate successfully blocked'
        redirect_to support_interface_fraud_auditing_matches_path
      else
        render :confirm_block_submission
      end
    end

  private

    def block_submission_params
      params.require(:support_interface_block_submission_form).permit(:accept_guidance)
    end
  end
end

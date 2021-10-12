module SupportInterface
  class FraudAuditingMatchesController < SupportInterfaceController
    def index
      @matches = FraudMatch.where(recruitment_cycle_year: RecruitmentCycle.current_year).all.sort_by(&:created_at)
    end

    def fraudulent
      fraud_match = FraudMatch.find(params[:id])

      if fraud_match.fraudulent
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

    def confirm_unblock_submission
      @candidate_to_unblock = UnblockSubmissionForm.new
    end

    def unblock_submission
      @candidate_to_unblock = UnblockSubmissionForm.new(unblock_submission_params)

      if @candidate_to_unblock.save(params[:fraud_match_id])
        flash[:success] = 'Candidate successfully unblocked'
        redirect_to support_interface_fraud_auditing_matches_path
      else
        render :confirm_unblock_submission
      end
    end

    def confirm_remove_access
      @candidate = Candidate.find(params[:candidate_id])
      @remove_access_form = RemoveAccessForm.new
    end

    def remove_access
      @candidate = Candidate.find(params[:candidate_id])
      @remove_access_form = RemoveAccessForm.new(remove_access_params)

      if @remove_access_form.save(@candidate)
        flash[:success] = 'Access successfully revoked'
        redirect_to support_interface_fraud_auditing_matches_path
      else
        render :confirm_remove_access
      end
    end

  private

    def block_submission_params
      params.require(:support_interface_block_submission_form).permit(:accept_guidance)
    end

    def unblock_submission_params
      params.require(:support_interface_unblock_submission_form).permit(:accept_guidance)
    end

    def remove_access_params
      params.require(:support_interface_remove_access_form).permit(:accept_guidance)
    end
  end
end

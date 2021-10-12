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
  end
end

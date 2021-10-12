module SupportInterface
  class FraudAuditingMatchesController < SupportInterfaceController
    def index
      @matches = FraudMatch.where(recruitment_cycle_year: RecruitmentCycle.current_year).all
    end
  end
end

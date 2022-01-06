module SupportInterface
  class DuplicateMatchesController < SupportInterfaceController
    def index
      @matches = FraudMatch.where(
        recruitment_cycle_year: RecruitmentCycle.current_year,
      ).order(:created_at)
    end

    def show
      @match = FraudMatch.find(params[:id])
    end
  end
end

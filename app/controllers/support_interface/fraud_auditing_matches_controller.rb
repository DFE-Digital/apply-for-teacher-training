module SupportInterface
  class FraudAuditingMatchesController < SupportInterfaceController
    def index
      @matches = GetFraudMatches.call
    end
  end
end

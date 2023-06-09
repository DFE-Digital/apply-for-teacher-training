module CandidateInterface
  class GuidanceController < CandidateInterfaceController
    skip_before_action :authenticate_candidate!

    def index
      @recruitment_cycle_year = 2023
    end
  end
end

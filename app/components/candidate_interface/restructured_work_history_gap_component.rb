module CandidateInterface
  class RestructuredWorkHistoryGapComponent < ViewComponent::Base
    include ViewHelper

    def initialize(break_period:)
      @break_period = break_period
    end
  end
end

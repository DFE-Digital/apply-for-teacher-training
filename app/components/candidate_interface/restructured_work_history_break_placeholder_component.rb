module CandidateInterface
  class RestructuredWorkHistoryBreakPlaceholderComponent < ViewComponent::Base
    include ViewHelper

    def initialize(break_period:)
      @break_period = break_period
    end
  end
end

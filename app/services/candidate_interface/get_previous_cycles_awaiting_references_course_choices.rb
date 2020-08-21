module CandidateInterface
  class GetPreviousCyclesAwaitingReferencesCourseChoices
    def self.call
      return [] unless EndOfCycleTimetable.between_cycles_apply_2?

      ApplicationChoice.includes(:course).awaiting_references
    end
  end
end

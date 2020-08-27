module CandidateInterface
  class GetPreviousCyclesAwaitingReferencesCourseChoices
    def self.call
      return [] unless EndOfCycleTimetable.between_cycles_apply_2?

      ApplicationChoice.includes(:course).joins(:course).where('courses.recruitment_cycle_year': RecruitmentCycle.current_year - 1).awaiting_references
    end
  end
end

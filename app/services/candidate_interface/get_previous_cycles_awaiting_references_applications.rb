module CandidateInterface
  class GetPreviousCyclesAwaitingReferencesApplications
    def self.call
      return [] unless EndOfCycleTimetable.between_cycles_apply_2?

      choices_awaiting_reference = ApplicationChoice
        .joins(:application_form)
        .where('application_forms.recruitment_cycle_year': RecruitmentCycle.current_year)
        .awaiting_references

      ApplicationForm
        .where(id: choices_awaiting_reference.select(:application_form_id))
    end
  end
end

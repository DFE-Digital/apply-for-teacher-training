module UCASMatches
  class RetrieveForApplicationChoice
    attr_accessor :candidate_id, :recruitment_cycle_year

    def initialize(application_choice)
      @candidate_id = application_choice.application_form.candidate.id
      @recruitment_cycle_year = application_choice.recruitment_cycle
    end

    def call
      UCASMatch.find_by(
        candidate_id: candidate_id,
        recruitment_cycle_year: recruitment_cycle_year,
      )
    end
  end
end

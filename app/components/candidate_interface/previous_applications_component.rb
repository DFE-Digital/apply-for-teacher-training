module CandidateInterface
  class PreviousApplicationsComponent < ViewComponent::Base
    include ViewHelper

    def initialize(candidate:, recruitment_cycle_year:)
      @candidate = candidate
      @recruitment_cycle_year = recruitment_cycle_year
    end

    def render?
      application_choices.present?
    end

    def application_choices
      ApplicationChoice
        .joins(:application_form)
        .where(application_forms: {
          candidate_id: @candidate.id,
          recruitment_cycle_year: @recruitment_cycle_year,
        })
        .where.not(status: 'unsubmitted')
        .where('NOT (application_forms.candidate_id = ? AND application_forms.recruitment_cycle_year = ?)',
               @candidate.id,
               RecruitmentCycleTimetable.current_year)
        .order(id: :desc)
    end
  end
end

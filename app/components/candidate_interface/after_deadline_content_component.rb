module CandidateInterface
  class AfterDeadlineContentComponent < ViewComponent::Base
    def initialize(application_form:)
      @application_form = application_form
    end

    def academic_year
      CycleTimetable.cycle_year_range(@application_form.recruitment_cycle_year)
    end

    def next_academic_year
      CycleTimetable.cycle_year_range(RecruitmentCycle.next_year)
    end

    def apply_opens_date
      I18n.l(CycleTimetable.apply_reopens.to_date, format: :no_year)
    end
  end
end

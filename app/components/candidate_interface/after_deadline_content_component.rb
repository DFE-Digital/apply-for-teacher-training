module CandidateInterface
  class AfterDeadlineContentComponent < ViewComponent::Base
    def initialize(application_form:)
      @application_form = application_form
    end

    def academic_year
      timetable.cycle_year_range_name
    end

    def next_academic_year
      timetable.relative_next_timetable.academic_year_range_name
    end

    def apply_opens_date
      timetable.relative_next_timetable.apply_opens_at.to_date.to_fs(:month_and_year)
    end

  private

    def timetable
      @timetable ||= @application_form.recruitment_cycle_timetable
    end
  end
end

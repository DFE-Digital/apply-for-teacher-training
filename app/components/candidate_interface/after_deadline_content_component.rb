module CandidateInterface
  class AfterDeadlineContentComponent < ViewComponent::Base
    def initialize(application_form:)
      @application_form = application_form
    end

    def academic_year
      timetable.academic_year_range_name
    end

    def next_academic_year
      timetable.relative_next_timetable.academic_year_range_name
    end

    def apply_opens_date
      timetable.relative_next_timetable.apply_opens_at.to_fs(:day_and_month)
    end

  private

    def timetable
      @timetable ||= @application_form.recruitment_cycle_timetable
    end
  end
end

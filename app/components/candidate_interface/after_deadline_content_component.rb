module CandidateInterface
  class AfterDeadlineContentComponent < ViewComponent::Base
    delegate :decline_by_default_at, to: :timetable

    def initialize(application_form:)
      @application_form = application_form
    end

    def academic_year
      timetable.academic_year_range_name
    end

    def next_academic_year
      next_timetable.academic_year_range_name
    end

    def apply_opens_date
      next_timetable.apply_opens_at.to_fs(:day_and_month)
    end

    def show_decline_by_default_text?
      timetable.between_apply_deadline_and_decline_by_default? && @application_form.offered?
    end

  private

    def timetable
      @timetable ||= @application_form.recruitment_cycle_timetable
    end

    def next_timetable
      @next_timetable || timetable.relative_next_timetable
    end
  end
end

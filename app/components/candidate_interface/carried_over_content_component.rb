module CandidateInterface
  class CarriedOverContentComponent < ViewComponent::Base
    def initialize(application_form:)
      @application_form = application_form
    end

    def academic_year
      timetable.relative_previous_timetable.academic_year_range_name
    end

    def next_academic_year
      timetable.academic_year_range_name
    end

    def apply_opens_date
      timetable.apply_opens_at.to_date.to_fs(:day_and_month)
    end

    def after_find_opens?
      Time.zone.now.after? timetable.find_opens_at
    end

    def timetable
      @timetable ||= @application_form.recruitment_cycle_timetable
    end
  end
end

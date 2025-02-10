module CandidateInterface
  class CarriedOverContentComponent < ViewComponent::Base
    def initialize(application_form:)
      @application_form = application_form
      @recruitment_cycle_timetable = application_form.recruitment_cycle_timetable
    end

    def academic_year
      @recruitment_cycle_timetable.relative_previous_timetable.academic_year_range_name
    end

    def next_academic_year
      @recruitment_cycle_timetable.academic_year_range_name
    end

    def apply_opens_date
      @recruitment_cycle_timetable.apply_opens_at.to_date.to_fs(:day_and_month)
    end

    def after_find_opens?
      Time.zone.now.after? @recruitment_cycle_timetable.find_opens_at
    end
  end
end

module CandidateInterface
  class CarriedOverContentComponent < ViewComponent::Base
    def initialize(application_form:)
      @application_form = application_form
    end

    def academic_year
      timetable.relative_previous_timetable.academic_year_range_name
    end

    def find_opens_date
      timetable.find_opens_at.to_fs(:govuk_date_time_time_first)
    end

    def after_find_opens?
      Time.zone.now.after? timetable.find_opens_at
    end

    def next_academic_year
      timetable.academic_year_range_name
    end

    def apply_opens_date
      timetable.apply_opens_at.to_fs(:govuk_date_time_time_first)
    end

    def timetable
      @timetable ||= RecruitmentCycleTimetable.next_timetable
    end
  end
end

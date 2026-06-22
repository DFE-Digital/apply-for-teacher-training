module CandidateInterface
  class PrepareForNextCycleContentComponent < ApplicationComponent
    delegate :recruitment_cycle_year, :recruitment_cycle_timetable, to: :application_form
    delegate :after_find_opens?, to: :next_recruitment_cycle

    attr_reader :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def next_recruitment_cycle
      if application_form.after_apply_deadline?
        recruitment_cycle_timetable.relative_next_timetable
      else
        recruitment_cycle_timetable
      end
    end

    def date_range
      next_recruitment_cycle.academic_year_range_name
    end

    def find_opens
      next_recruitment_cycle.find_opens_at.to_fs(:govuk_date_time_time_first)
    end

    def apply_opens
      next_recruitment_cycle.apply_opens_at.to_fs(:govuk_date_time_time_first)
    end

    def show_button?
      after_find_opens? && !next_recruitment_cycle.after_apply_deadline? &&
        application_form.can_submit_more_choices?
    end
  end
end

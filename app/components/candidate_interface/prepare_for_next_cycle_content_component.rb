module CandidateInterface
  class PrepareForNextCycleContentComponent < ApplicationComponent
    delegate :recruitment_cycle_timetable, to: :application_form
    delegate :after_find_opens?, :academic_year_range_name, to: :next_recruitment_cycle

    attr_reader :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def application_choices
      return [] unless next_recruitment_cycle == RecruitmentCycleTimetable.current_timetable

      CandidateInterface::SortApplicationChoices.call(
        application_choices: application_form.application_choices.for_sorting,
      )
    end

    def next_recruitment_cycle
      @next_recruitment_cycle ||= if application_form.after_apply_deadline?
                                    recruitment_cycle_timetable.relative_next_timetable
                                  else
                                    recruitment_cycle_timetable
                                  end
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

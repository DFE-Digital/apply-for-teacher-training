module CycleTimetableServices
  class ApplicationFormMethods
    attr_reader :recruitment_cycle_timetable, :application_form
    delegate_missing_to :recruitment_cycle_timetable
    def initialize(
      application_form:, recruitment_cycle_timetable: RecruitmentCycleTimetable.current_real_timetable
    )
      @application_form = application_form
      @recruitment_cycle_timetable = recruitment_cycle_timetable
    end

    def valid_cycle?
      application_form.recruitment_cycle_year == recruitment_cycle_timetable.recruitment_cycle_year
    end

    def can_add_course_choice?
      valid_cycle? && current_date.between?(find_opens, apply_deadline)
    end

    def can_submit?
      valid_cycle? && current_date.between?(apply_opens, apply_deadline)
    end

    def before_apply_opens?
      current_date < apply_opens
    end

    def apply_deadline_has_passed?
      valid_cycle? && current_date.after?(apply_deadline)
    end

    def show_apply_deadline_banner?
      valid_cycle? &&
        !application_form.successful? &&
        current_date.between?(show_deadline_banner_date, apply_deadline)
    end

    def show_deadline_banner_date
      apply_deadline - 5.weeks
    end

  private

    def current_date
      Time.zone.now
    end
  end
end

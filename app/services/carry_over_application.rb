class CarryOverApplication
  def initialize(application_form)
    @application_form = application_form
  end

  def call
    raise_if_application_from_current_cycle

    DuplicateApplication.new(
      @application_form,
      recruitment_cycle_year:,
    ).duplicate
  end

private

  def raise_if_application_from_current_cycle
    unless @application_form.after_apply_deadline?
      raise ArgumentError, 'You can only carry an application over from a previous recruitment cycle'
    end
  end

  def recruitment_cycle_year
    if RecruitmentCycleTimetable.current_timetable.after_apply_deadline?
      RecruitmentCycleTimetable.next_year
    else
      RecruitmentCycleTimetable.current_year
    end
  end
end

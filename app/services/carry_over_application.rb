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
    if application_from_current_cycle?
      raise ArgumentError, 'You can only carry an application over from a previous recruitment cycle'
    end
  end

  def application_from_current_cycle?
    @application_form.recruitment_cycle_year == recruitment_cycle_year
  end

  def recruitment_cycle_year
    if Time.zone.now > CycleTimetable.apply_deadline
      RecruitmentCycle.next_year
    else
      RecruitmentCycle.current_year
    end
  end
end

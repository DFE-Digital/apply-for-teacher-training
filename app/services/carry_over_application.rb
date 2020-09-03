class CarryOverApplication
  def initialize(application_form)
    @application_form = application_form
  end

  def call
    raise_if_application_from_current_cycle

    DuplicateApplication.new(@application_form, target_phase: 'apply_1').duplicate
  end

private

  def raise_if_application_from_current_cycle
    if application_from_current_cycle?
      raise ArgumentError, 'You can only carry an application over from a previous recruitment cycle'
    end
  end

  def application_from_current_cycle?
    new_recruitment_cycle_year = EndOfCycleTimetable.between_cycles_apply_2? ? EndOfCycleTimetable.next_cycle_year : RecruitmentCycle.current_year

    @application_form.application_choices.any? do |application_choice|
      application_choice.course.recruitment_cycle_year == new_recruitment_cycle_year
    end
  end
end

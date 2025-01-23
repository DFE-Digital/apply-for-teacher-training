class CycleCommunicationsScheduler
  def initialize(recruitment_cycle_timetable: RecruitmentCycleTimetable.current_real_timetable)
    @recruitment_cycle_timetable = recruitment_cycle_timetable
  end
  attr_reader :recruitment_cycle_timetable

  def show_apply_deadline_banner?(application_form)
    # Only show the banner if the application_form is for this recruitment cycle
    application_form.recruitment_cycle_year == recruitment_cycle_timetable.recruitment_cycle_year &&
      # AND The application has not been successful (recruited, pending conditions)
      !application_form.successful? &&
      # AND we are approaching the apply deadline
      Time.zone.now.between?(deadline_approaching_banner_date, recruitment_cycle_timetable.apply_deadline)
  end

  def deadline_approaching_banner_date
    recruitment_cycle_timetable.apply_deadline - 5.weeks
  end
end

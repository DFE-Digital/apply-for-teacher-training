module CycleTimetableHelper
module_function

  def seed_timetables
    SeedTimetablesService.seed_from_csv
  end

  def current_year
    current_timetable.recruitment_cycle_year
  end

  def previous_timetable
    current_timetable.relative_previous_timetable
  end

  def previous_year
    previous_timetable.recruitment_cycle_year
  end

  def current_timetable
    get_timetable
  end

  def current_cycle_week
    seed_timetables if RecruitmentCycleTimetable.none?
    RecruitmentCycleTimetable.current_cycle_week
  end

  def last_timetable
    seed_timetables if RecruitmentCycleTimetable.none?
    RecruitmentCycleTimetable.last_timetable
  end

  def next_timetable
    current_timetable.relative_next_timetable
  end

  def next_year
    next_timetable.recruitment_cycle_year
  end

  def years_visible_to_providers
    seed_timetables if RecruitmentCycleTimetable.all.empty?
    RecruitmentCycleTimetable.years_visible_to_providers
  end

  def this_day_last_cycle
    seed_timetables if RecruitmentCycleTimetable.all.empty?
    RecruitmentCycleTimetable.this_day_last_cycle
  end

  def after_find_opens(year = nil)
    timetable = get_timetable(year)
    timetable.find_opens_at + 1.day
  end

  def after_find_closes(year = nil)
    timetable = get_timetable(year)
    timetable.find_closes_at + 1.second
  end

  def after_find_reopens(year = nil)
    timetable = get_timetable(year)
    timetable.relative_next_timetable.find_opens_at + 1.day
  end

  def mid_cycle(year = nil)
    timetable = get_timetable(year)
    timetable.apply_opens_at + 1.day
  end

  def after_apply_deadline(year = nil)
    timetable = get_timetable(year)
    timetable.apply_deadline_at + 1.day
  end

  def cancel_application_deadline(year = nil)
    timetable = get_timetable(year)
    timetable.apply_deadline_at
  end

  def before_apply_deadline(year = nil)
    timetable = get_timetable(year)
    timetable.apply_deadline_at - 1.day
  end

  def after_apply_reopens(year = nil)
    seed_timetables if RecruitmentCycleTimetable.all.empty?
    year = (year || RecruitmentCycleTimetable.current_year) + 1

    timetable = get_timetable(year)
    timetable.apply_opens_at + 1.day
  end

  def after_reject_by_default(year = nil)
    timetable = get_timetable(year)
    timetable.reject_by_default_at + 1.day
  end

  def reject_by_default_run_date(year = nil)
    timetable = get_timetable(year)
    timetable.reject_by_default_at + 1.second
  end

  def decline_by_default_run_date(year = nil)
    timetable = get_timetable(year)
    timetable.decline_by_default_at + 1.second
  end

  def application_deadline_has_passed_email_date(year = nil)
    timetable = get_timetable(year)
    timetable.apply_deadline_at + 1.day
  end

  def reject_by_default_explainer_date(year = nil)
    timetable = get_timetable(year)
    timetable.reject_by_default_at + 1.day
  end

  def get_timetable(year = nil)
    seed_timetables if RecruitmentCycleTimetable.all.empty?

    if year.present?
      RecruitmentCycleTimetable.find_by(recruitment_cycle_year: year)
    else
      RecruitmentCycleTimetable.current_timetable
    end
  end
end

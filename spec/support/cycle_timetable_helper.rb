module CycleTimetableHelper
module_function

  require_relative 'seed_recruitment_cycle_timetables'

  def seed_timetables
    SeedRecruitmentCycleTimetables.call
  end

  def last_available_year
    seed_timetables if RecruitmentCycleTimetable.all.empty?

    RecruitmentCycleTimetable.pluck(:recruitment_cycle_year).max
  end

  def after_find_opens(year = nil)
    timetable = get_timetable(year)
    timetable.find_opens_at + 1.day
  end

  def after_find_closes(year)
    timetable = get_timetable(year)
    timetable.find_closes_at + 1.second
  end

  def after_find_reopens(year = nil)
    timetable = get_timetable(year + 1)
    timetable.find_opens_at + 1.day
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
    timetable.reject_by_default_at(year) + 1.day
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

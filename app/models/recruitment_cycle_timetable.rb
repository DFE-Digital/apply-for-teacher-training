class RecruitmentCycleTimetable < ApplicationRecord
  validates :recruitment_cycle_year,
            :find_opens_at,
            :apply_opens_at,
            :apply_deadline_at,
            :reject_by_default_at,
            :decline_by_default_at,
            :find_closes_at,
            presence: true
  validates :recruitment_cycle_year, uniqueness: { allow_nil: false }
  validates_with RecruitmentCycleTimetableDateSequenceValidator

  scope :current_and_past, -> { where('recruitment_cycle_year <= ?', RecruitmentCycleTimetable.current_year) }

  def self.find_timetable_by_datetime(datetime)
    where('find_opens_at < ?', datetime).order(:recruitment_cycle_year).last
  end

  def self.find_cycle_week_by_datetime(datetime)
    timetable = find_timetable_by_datetime(datetime)
    weeks = (datetime - timetable.find_opens_at.beginning_of_week).seconds.in_weeks.to_i
    (weeks % 53).succ
  end

  def self.current_and_past_years
    current_and_past.pluck(:recruitment_cycle_year).sort
  end

  def self.current_timetable
    # We cannot just look for the timetable where now is between find_open_at and find_closes_at
    # because there is a gap from 23:23 to 9am the next day (typically) between find closing and reopening for the new cycle.
    # We haven't started a new cycle until find_opens, so if we are in that 8 hour gap, we want the earlier cycle.
    # eg, if we are 4 hours before the find_opens_at for the 2025 cycle, we want to return the 2024 cycle.
    where('find_opens_at <= ?', Time.zone.now).order(:recruitment_cycle_year).last
  end

  def self.current_cycle_range_name
    current_timetable.cycle_range_name
  end

  def self.current_academic_year_range_name
    current_timetable.academic_year_range_name
  end

  def self.currently_between_cycles?
    current_timetable.between_cycles?
  end

  def self.next_timetable
    where('find_opens_at > ?', Time.zone.now).order(:recruitment_cycle_year).first
  end

  def self.previous_timetable
    where('find_opens_at <= ?', Time.zone.now).order(:recruitment_cycle_year).second_to_last
  end

  def self.previous_cycle_range_name
    previous_timetable.cycle_range_name
  end

  def self.current_year
    current_timetable.recruitment_cycle_year
  end

  def self.previous_year
    previous_timetable.recruitment_cycle_year
  end

  def self.next_year
    next_timetable.recruitment_cycle_year
  end

  def self.years_visible_in_support
    max_year = HostingEnvironment.production? ? current_year : next_year

    pluck(:recruitment_cycle_year).reject { |year| year > max_year }
  end

  def self.years_visible_to_providers
    [previous_year, current_year]
  end

  def self.current_cycle_week
    weeks = (Time.zone.now - current_timetable.find_opens_at.beginning_of_week).seconds.in_weeks.to_i
    (weeks % 53).succ
  end

  def self.this_day_last_cycle
    days_since_cycle_started = (Time.zone.now.to_date - current_timetable.apply_opens_at.to_date).round
    last_cycle_opening_date = previous_timetable.apply_opens_at.to_date
    last_cycle_date = days_since_cycle_started.days.after(last_cycle_opening_date)
    DateTime.new(last_cycle_date.year, last_cycle_date.month, last_cycle_date.day, Time.current.hour, Time.current.min, Time.current.sec)
  end

  def self.last_timetable
    order(:recruitment_cycle_year).last
  end

  def cycle_range_name
    "#{recruitment_cycle_year - 1} to #{recruitment_cycle_year}"
  end

  def cycle_range_name_with_current_indicator
    if recruitment_cycle_year == RecruitmentCycleTimetable.current_year
      "#{cycle_range_name} - current"
    else
      cycle_range_name
    end
  end

  def academic_year_range_name
    "#{recruitment_cycle_year} to #{recruitment_cycle_year + 1}"
  end

  def next_available_academic_year_range
    if after_apply_deadline?
      relative_next_timetable.academic_year_range_name
    else
      academic_year_range_name
    end
  end

  def previously_closed_academic_year_range
    if after_apply_deadline?
      academic_year_range_name
    else
      relative_previous_timetable.academic_year_range_name
    end
  end

  def relative_next_timetable
    self.class.find_by(recruitment_cycle_year: recruitment_cycle_year + 1)
  end

  def relative_previous_timetable
    self.class.find_by(recruitment_cycle_year: recruitment_cycle_year - 1)
  end

  def relative_next_year
    recruitment_cycle_year + 1
  end

  def relative_previous_year
    recruitment_cycle_year - 1
  end

  def apply_reopens_at
    if before_apply_opens?
      apply_opens_at
    else
      relative_next_timetable.apply_opens_at
    end
  end

  def find_reopens_at
    relative_next_timetable.find_opens_at
  end

  def cycle_week_date_range(cycle_week)
    cycle_week %= 52
    cycle_week -= 1

    start_of_week = find_opens_at + cycle_week.weeks
    start_of_week.all_week
  end

  def after_find_closes?
    Time.zone.now.after? find_closes_at
  end

  def after_decline_by_default?
    Time.zone.now.after? decline_by_default_at
  end

  def after_reject_by_default?
    Time.zone.now.after? reject_by_default_at
  end

  def after_apply_deadline?
    Time.zone.now.after? apply_deadline_at
  end

  def after_apply_opens?
    Time.zone.now.after? apply_opens_at
  end

  def before_apply_opens?
    Time.zone.now.before? apply_opens_at
  end

  def after_find_opens?
    Time.zone.now.after? find_opens_at
  end

  def between_cycles?
    before_apply_opens? || after_apply_deadline?
  end

  def approaching_apply_deadline?
    Time.zone.now.after? show_banners_at
  end

  def next_year?
    self == RecruitmentCycleTimetable.next_timetable
  end

  def current_year?
    self == RecruitmentCycleTimetable.current_timetable
  end

  def previous_year?
    self == RecruitmentCycleTimetable.previous_timetable
  end

  def show_banners_at
    12.weeks.before apply_deadline_at
  end

private

  def cycle_range
    find_opens_at..find_closes_at
  end
end

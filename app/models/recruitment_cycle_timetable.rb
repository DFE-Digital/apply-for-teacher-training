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
  validate :christmas_holiday_validation
  validate :easter_holiday_validation

  def self.current_timetable
    # We cannot just look for the timetable where now is between find_open_at and find_closes_at
    # because there is a gap from 23:23 to 9am the next day (typically) between find closing and reopening for the new cycle.
    # We haven't started a new cycle until find_opens, so if we are in that 8 hour gap, we want the earlier cycle.
    # eg, if we are 4 hours before the find_opens_at for the 2025 cycle, we want to return the 2024 cycle.
    where('find_opens_at <= ?', Time.zone.now).order(:recruitment_cycle_year).last
  end

  def self.next_timetable
    where('find_opens_at > ?', Time.zone.now).order(:recruitment_cycle_year).first
  end

  def self.previous_timetable
    where('find_opens_at <= ?', Time.zone.now).order(:recruitment_cycle_year).second_to_last
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

  def self.current_cycle_week
    weeks = (Time.zone.now - current_timetable.find_opens_at.beginning_of_week).seconds.in_weeks.to_i
    (weeks % 53).succ
  end

  def cycle_range_name
    "#{recruitment_cycle_year - 1} to #{recruitment_cycle_year}"
  end

  def academic_year_range_name
    "#{recruitment_cycle_year} to #{recruitment_cycle_year + 1}"
  end

  def relative_next_timetable
    self.class.find_by(recruitment_cycle_year: recruitment_cycle_year + 1)
  end

  def relative_previous_timetable
    self.class.find_by(recruitment_cycle_year: recruitment_cycle_year - 1)
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

  def after_find_opens?
    Time.zone.now.after? find_opens_at
  end

private

  def christmas_holiday_validation
    return if [christmas_holiday_range, find_opens_at, find_closes_at].any?(&:blank?)

    holidays = Holidays.between(
      christmas_holiday_range.first,
      christmas_holiday_range.last, :gb
    ).map do |holiday|
      holiday[:name]
    end

    if !christmas_holiday_range.in? cycle_range
      errors.add(:christmas_holiday_range, :christmas_holiday_range_should_be_in_cycle)
    elsif holidays.exclude? 'Christmas Day'
      errors.add(:christmas_holiday_range, :christmas_holiday_range_should_include_christmas)
    end
  end

  def easter_holiday_validation
    return if [easter_holiday_range, find_opens_at, find_closes_at].any?(&:blank?)

    holidays = Holidays.between(
      easter_holiday_range.first,
      easter_holiday_range.last, :gb
    ).map do |holiday|
      holiday[:name]
    end

    if !easter_holiday_range.in? cycle_range
      errors.add(:easter_holiday_range, :easter_holiday_range_should_be_within_cycle)

    elsif holidays.exclude?('Easter Sunday')
      errors.add(:easter_holiday_range, :easter_holiday_range_should_include_easter)
    end
  end

  def cycle_range
    find_opens_at..find_closes_at
  end

  def sequential_dates
    return if [
      find_opens_at,
      apply_opens_at,
      apply_deadline_at,
      reject_by_default_at,
      decline_by_default_at,
      find_closes_at,
    ].any?(&:blank?)

    if find_opens_at.after? apply_opens_at
      errors.add(:apply_opens_at, :apply_opens_after_find_opens)
    elsif apply_opens_at.after? apply_deadline_at
      errors.add(:apply_deadline_at, :apply_deadline_after_apply_opens)
    elsif apply_deadline_at.after? reject_by_default_at
      errors.add(:reject_by_default_at, :reject_by_default_after_apply_deadline)
    elsif reject_by_default_at.after? decline_by_default_at
      errors.add(:decline_by_default_at, :decline_by_default_after_reject_by_default)
    elsif decline_by_default_at.after? find_closes_at
      errors.add(:find_closes_at, :find_closes_after_decline_by_default)
    end
  end
end

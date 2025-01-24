class RecruitmentCycleTimetable < ApplicationRecord
  validates :recruitment_cycle_year,
            :find_opens,
            :apply_opens,
            :apply_deadline,
            :reject_by_default,
            :decline_by_default,
            :find_closes,
            presence: true
  validates :recruitment_cycle_year, uniqueness: { scope: [:real_timetable] }, if: :real_timetable?
  validate :sequential_dates

  scope :real_timetables, -> { where(real_timetable: true) }

  def self.current_real_timetable
    real_timetables.find_by('find_opens <= ? AND find_closes > ?', Time.zone.now, Time.zone.now)
  end

  def self.real_current_year
    current_real_timetable.try(:recruitment_cycle_year)
  end

  def self.real_timetable_for(recruitment_cycle_year)
    real_timetables.find_by(recruitment_cycle_year:)
  end

  def self.real_timetable_for_time(time)
    years = [time.year, time.year + 1]
    # We can't do time between find_opens and find_closes,
    # because there is 8 hours between find_closing and reopening in the next cycle.
    real_timetables
      # eg, in November 2024, we are in the 2025 cycle. In August 2024, we are in the 2024 cycle.
      .where(recruitment_cycle_year: years)
      # After the cycle has started, eg, in August 2024, the 2025 cycle would not have started, so it would be filtered out here.
      .where('find_opens <= ?', time)
      .order(:recruitment_cycle_year).last
  end

  def find_reopens
    self.class.where(real_timetable:)
        .find_by('find_opens > ?', find_opens)&.find_opens ||
      (find_closes + 8.hours)
  end

  def apply_reopens
    self.class.where(real_timetable:)
        .find_by('apply_opens > ?', apply_opens)&.apply_opens ||
      (find_reopens + 1.week)
  end

  def find_down?
    Time.zone.now.after?(find_closes, find_reopens)
  end

  def between_cycles?
    Time.zone.now.before?(apply_opens) || Time.zone.now.between?(apply_deadline, apply_reopens)
  end

private

  def sequential_dates
    required_dates = [
      find_opens,
      apply_opens,
      apply_deadline,
      reject_by_default,
      decline_by_default,
      find_closes,
    ]

    return if required_dates.any?(&:blank?)

    if find_opens > apply_opens
      errors.add(:apply_opens, :apply_opens_after_find_opens)
    elsif apply_opens > apply_deadline
      errors.add(:apply_deadline, :apply_deadline_after_apply_opens)
    elsif apply_deadline > reject_by_default
      errors.add(:reject_by_default, :reject_by_default_after_apply_deadline)
    elsif reject_by_default > decline_by_default
      errors.add(:decline_by_default, :decline_by_default_after_reject_by_default)
    elsif decline_by_default > find_closes
      errors.add(:find_closes, :find_closes_after_decline_by_default)
    end
  end
end

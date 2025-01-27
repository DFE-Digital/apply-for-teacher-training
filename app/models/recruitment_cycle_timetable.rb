class RecruitmentCycleTimetable < ApplicationRecord
  validates :recruitment_cycle_year,
            :find_opens,
            :apply_opens,
            :apply_deadline,
            :reject_by_default,
            :decline_by_default,
            :find_closes,
            presence: true
  validates :recruitment_cycle_year, uniqueness: { allow_nil: false }
  validate :sequential_dates

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

class RecruitmentCycleTimetableDateSequenceValidator < ActiveModel::Validator
  delegate :find_opens_at,
           :apply_opens_at,
           :apply_deadline_at,
           :reject_by_default_at,
           :decline_by_default_at,
           :find_closes_at,
           :errors,
           to: :record
  attr_reader :record
  def validate(record)
    @record = record

    return if blank_attributes?

    check_for_invalid_dates

    return if errors.any?

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

  def blank_attributes?
    [
      find_opens_at,
      apply_opens_at,
      apply_deadline_at,
      reject_by_default_at,
      decline_by_default_at,
      find_closes_at,
    ].any?(&:blank?)
  end

  def check_for_invalid_dates
    %i[
      find_opens_at
      apply_opens_at
      apply_deadline_at
      reject_by_default_at
      decline_by_default_at
      find_closes_at
    ].each do |attr|
      value = record.send(attr)
      errors.add(attr, :invalid_date) unless value.respond_to? :to_date
      errors.add(attr, :invalid_date) if value.year.to_i < 2018
      errors.add(attr, :invalid_date) if value.year.to_i > 2050
    end
  end
end

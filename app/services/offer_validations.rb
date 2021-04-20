class OfferValidations
  include ActiveModel::Model

  MAX_CONDITIONS_COUNT = 20
  MAX_CONDITION_LENGTH = 255

  attr_accessor :course_option, :conditions

  validates :course_option, presence: true
  validate :course_option_open_on_apply, if: :course_option
  validate :conditions_count, if: :conditions
  validate :conditions_length, if: :conditions

  def course_option_open_on_apply
    errors.add(:course_option, :not_open_on_apply) unless course_option.course.open_on_apply?
  end

  def conditions_count
    return if conditions.count <= MAX_CONDITIONS_COUNT

    errors.add(:conditions, :too_many, count: MAX_CONDITIONS_COUNT)
  end

  def conditions_length
    conditions.each_with_index do |condition, index|
      errors.add(:conditions, :too_long, index: index + 1, limit: MAX_CONDITION_LENGTH) if condition.length > MAX_CONDITION_LENGTH
    end
  end
end

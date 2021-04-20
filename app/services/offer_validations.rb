class OfferValidations
  include ActiveModel::Model

  attr_accessor :course_option

  validates :course_option, presence: true
  validate :course_option_open_on_apply, if: :course_option

  def course_option_open_on_apply
    errors.add(:course_option, :not_open_on_apply) unless course_option.course.open_on_apply?
  end
end

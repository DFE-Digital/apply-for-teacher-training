class ConfirmDeferredOfferValidations
  include ActiveModel::Model

  attr_accessor :application_choice, :course_option

  validates :course_option, presence: true
  validate :course_open_in_apply, if: :course_option
  validate :course_exists_in_current_cycle, if: :course_option

  def course_open_in_apply
    if !course_option.course.open_on_apply
      errors.add(:course_option, :not_open_on_apply)
    end
  end

  def course_exists_in_current_cycle
    if course_option.course.recruitment_cycle_year != RecruitmentCycle.current_year
      errors.add(:course_option, :not_in_current_cycle)
    end
  end
end

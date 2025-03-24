class ConfirmDeferredOfferValidations
  include ActiveModel::Model

  attr_accessor :application_choice, :course_option

  validates :course_option, presence: true
  validate :course_exists_in_current_cycle, if: :course_option

  def course_exists_in_current_cycle
    if course_option.course.recruitment_cycle_year != current_year
      errors.add(:course_option, :not_in_current_cycle)
    end
  end

  def current_year
    @current_year ||= RecruitmentCycleTimetable.current_year
  end
end

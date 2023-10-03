class CourseValidations
  include ActiveModel::Model

  attr_accessor :application_choice, :course_option

  validates :course_option, presence: true
  validate :ratifying_provider_changed?, if: %i[application_choice course_option]
  validate :identical_to_existing_course?, if: %i[application_choice course_option]
  validate :course_already_exists_on_application?, if: %i[application_choice course_option]

  def ratifying_provider_changed?
    if application_choice.current_course.ratifying_provider != course_option.course.ratifying_provider
      errors.add(:base, :different_ratifying_provider)
    end
  end

  def identical_to_existing_course?
    raise IdenticalCourseError if application_choice.current_course_option == course_option
  end

  def course_already_exists_on_application?
    application_choice.course_option = course_option

    raise ExistingCourseError if application_choice.invalid?(:reappliable)
  end
end

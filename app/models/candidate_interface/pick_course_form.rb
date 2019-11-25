module CandidateInterface
  class PickCourseForm
    include ActiveModel::Model

    attr_accessor :code, :provider_code, :application_form
    validates :code, presence: true
    validate :user_cant_apply_to_same_course_twice

    def other?
      code == 'other'
    end

    def available_courses
      Provider
        .find_by!(code: provider_code)
        .courses
        .where(exposed_in_find: true)
        .order(:name)
    end

  private

    def user_cant_apply_to_same_course_twice
      if application_form.application_choices.any? { |application_choice| application_choice.course == course }
        errors[:base] << 'You have already selected this course'
      end
    end

    def course
      @course ||= Course.find_by!(code: code)
    end
  end
end

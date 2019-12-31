module CandidateInterface
  class PickCourseForm
    include ActiveModel::Model

    attr_accessor :code, :provider_code, :application_form
    validates :code, presence: true
    validate :user_cant_apply_to_same_course_twice

    def applyable?
      !other? && course.open_on_apply?
    end

    def other?
      code == 'other'
    end

    def available_courses
      @available_courses ||= begin
        provider.courses.visible_to_candidates.order(:name)
      end
    end

    def single_site?
      course_id = Course.find_by(code: code)
      CourseOption.where(course_id: course_id).one?
    end

  private

    def provider
      @provider ||= Provider.find_by!(code: provider_code)
    end

    def user_cant_apply_to_same_course_twice
      return unless code

      if application_form.application_choices.any? { |application_choice| application_choice.course == course }
        errors[:base] << 'You have already selected this course'
      end
    end

    def course
      @course ||= Course.find_by!(code: code)
    end
  end
end

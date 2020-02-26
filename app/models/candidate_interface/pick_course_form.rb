module CandidateInterface
  class PickCourseForm
    include ActiveModel::Model

    attr_accessor :course_id, :provider_id, :application_form
    validates :course_id, presence: true
    validate :user_cant_apply_to_same_course_twice

    def open_on_apply?
      course.open_on_apply?
    end

    def available_courses
      @available_courses ||= begin
        provider.courses.exposed_in_find.order(:name)
      end
    end

    def single_site?
      CourseOption.where(course_id: course.id).one?
    end

    def both_study_modes_available?
      course.study_mode == 'full_time_or_part_time'
    end

    def course
      @course ||= provider.courses.find(course_id)
    end

  private

    def provider
      @provider ||= Provider.find(provider_id)
    end

    def user_cant_apply_to_same_course_twice
      return if course_id.blank?

      if application_form.application_choices.any? { |application_choice| application_choice.course == course }
        errors[:base] << 'You have already selected this course'
      end
    end
  end
end

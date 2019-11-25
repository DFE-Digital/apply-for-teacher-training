module CandidateInterface
  class PickSiteForm
    include ActiveModel::Model

    attr_accessor :application_form, :provider_code, :course_code, :course_option_id
    validates :course_option_id, presence: true
    validate :user_cant_apply_to_same_course_twice

    def available_sites
      CourseOption.where(course_id: course.id)
    end

    def save
      return unless valid?

      application_form.application_choices.create!(
        course_option: course_option,
      )
    end

    def course_option
      CourseOption.find(course_option_id)
    end

    def course
      provider = Provider.find_by!(code: provider_code)
      provider.courses.find_by!(code: course_code)
    end

    def user_cant_apply_to_same_course_twice
      if application_form.application_choices.any? { |application_choice| application_choice.course == course }
        errors[:base] << 'You have already selected this course'
      end
    end
  end
end

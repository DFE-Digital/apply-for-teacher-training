module CandidateInterface
  class PickCourseForm
    include ActiveModel::Model

    attr_accessor :course_id, :provider_id, :application_form
    validates :course_id, presence: true
    validate :user_cant_apply_to_same_course_twice

    def open_on_apply?
      course.open_on_apply?
    end

    DropdownOption = Struct.new(:id, :name)

    def radio_available_courses
      @radio_available_courses ||= begin
        provider.courses.exposed_in_find.order(:name)
      end
    end

    def dropdown_available_courses
      @dropdown_available_courses ||= begin
        courses = provider.courses.exposed_in_find.includes(:accredited_provider)

        courses_with_names = courses.map(&:name).map(&:downcase)
        courses_with_descriptions = courses.map(&:name_and_description).map(&:downcase)
        courses_with_name_provider_and_description = courses.map(&:name_provider_and_description).map(&:downcase)

        courses_with_unambiguous_names = courses.map do |course|
          name = if courses_with_names.count(course.name.downcase) == 1
                   course.name_and_code
                 elsif courses_with_descriptions.count(course.name_and_description.downcase) == 1
                   course.name_code_and_description
                 elsif courses_with_name_provider_and_description.count(course.name_provider_and_description.downcase) == 1
                   course.name_code_and_provider
                 else
                   course.name_and_code
                 end

          DropdownOption.new(course.id, name)
        end

        courses_with_unambiguous_names.sort_by(&:name)
      end
    end

    def single_site?
      CourseOption.where(course_id: course.id).one?
    end

    def both_study_modes_available?
      course.both_study_modes_available?
    end

    def study_mode
      course.study_mode
    end

    def full?
      course.full?
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

      if application_form.application_choices.includes([:course]).any? { |application_choice| application_choice.course == course }
        errors[:base] << I18n.t!('errors.application_choices.already_added', course_name_and_code: course.name_and_code)
      end
    end
  end
end

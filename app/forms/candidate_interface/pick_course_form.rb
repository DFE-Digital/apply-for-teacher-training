module CandidateInterface
  class PickCourseForm
    include ActiveModel::Model

    attr_accessor :course_id, :provider_id, :application_form
    attr_writer :available_courses
    validates :course_id, presence: true

    DropdownOption = Struct.new(:id, :name)
    RadioOption = Struct.new(:id, :label, :hint)

    def radio_available_courses
      @radio_available_courses ||= available_courses.map do |course|
        label = course.name_and_code
        label += ' – No vacancies' unless course.available?
        hint = course.description_to_s

        RadioOption.new(course.id, label, hint)
      end
    end

    def dropdown_available_courses
      @dropdown_available_courses ||= begin
        courses = available_courses

        courses_with_unambiguous_names = courses.map do |course|
          name = unique_name_for(course) || course.name_and_code
          name += ' – No vacancies' unless course.available?

          DropdownOption.new(course.id, name)
        end

        courses_with_unambiguous_names.sort_by(&:name)
      end
    end

    def single_site?
      available_course_options.one?
    end

    def available_course_options
      Course.find(course_id).course_options.available
    end

    delegate :available?, :currently_has_both_study_modes_available?, :full?,
             :available_study_modes_with_vacancies, :study_mode, to: :course

    def course
      @course ||= provider.courses.find(course_id)
    end

  private

    def provider
      @provider ||= Provider.find(provider_id)
    end

    def unique_name_for(course)
      return course.name_code_and_description if course.undergraduate?

      if courses_with_names.count(course.name.downcase) == 1
        course.name_and_code
      elsif courses_with_descriptions.count(course.name_and_description.downcase) == 1
        course.name_code_and_description
      elsif courses_with_name_provider_and_description.count(course.name_provider_and_description.downcase) == 1
        course.name_code_and_provider
      elsif courses_with_name_description_provider_and_age_range.count(course.name_description_provider_and_age_range.downcase) == 1 && course.age_range.present?
        course.name_code_and_age_range
      end
    end

    def available_courses
      @available_courses ||= GetAvailableCoursesForProvider.new(provider).call
    end

    def courses_with_names
      available_courses.map(&:name).map(&:downcase)
    end

    def courses_with_descriptions
      available_courses.map(&:name_and_description).map(&:downcase)
    end

    def courses_with_name_provider_and_description
      available_courses.map(&:name_provider_and_description).map(&:downcase)
    end

    def courses_with_name_description_provider_and_age_range
      available_courses.map(&:name_description_provider_and_age_range).map(&:downcase)
    end
  end
end

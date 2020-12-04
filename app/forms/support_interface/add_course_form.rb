module SupportInterface
  class AddCourseForm
    include ActiveModel::Model

    attr_accessor :course_option_id, :application_form_id, :candidate_id

    validates :course_option_id, presence: true
    validates :application_form_id, presence: true

    DropdownOption = Struct.new(:id, :name)

    def radio_available_courses
      @radio_available_courses ||= begin
        courses.order(:name)
      end
    end

    def dropdown_available_courses
      @dropdown_available_courses ||= courses.map { |course|
        # YUCK

        course.course_options.map do |course_option|
          DropdownOption.new(course_option.id, "#{course.name} (#{course.code}) – #{course.provider&.name} - #{course_option.site.name}")
        end
      }.flatten.sort_by(&:name)
    end

    def courses
      @courses ||= Course.current_cycle.includes(:provider, { course_options: [:site] }).open_on_apply
    end

    def save
      return false unless valid?

      SupportInterface::AddCourseChoiceAfterSubmission.new(
        application_form: application_form,
        course_option: course_option,
      ).call
    end

    def application_form
      @application_form ||= ApplicationForm.find(application_form_id)
    end

    def course_option
      @course_option ||= CourseOption.find(course_option_id)
    end
  end
end

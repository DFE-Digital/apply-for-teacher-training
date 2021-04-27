module SupportInterface
  class AddCourseChoiceAfterSubmission
    attr_reader :application_form, :course_option

    def initialize(application_form:, course_option:)
      @application_form = application_form
      @course_option = course_option
    end

    def call
      application_choice = ApplicationChoice.create!(
        application_form: application_form,
        course_option: course_option,
        current_course_option: course_option,
        status: 'unsubmitted',
      )

      SendApplicationToProvider.call(application_choice)

      application_choice
    end
  end
end

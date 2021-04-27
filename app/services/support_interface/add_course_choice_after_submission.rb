module SupportInterface
  class AddCourseChoiceAfterSubmission
    attr_reader :application_form, :course_option

    def initialize(application_form:, course_option:)
      @application_form = application_form
      @course_option = course_option
    end

    def call
      application_choice = ApplicationChoice.new(
        application_form: application_form,
        status: 'unsubmitted',
      )
      application_choice.set_initial_course_choice!(course_option)

      SendApplicationToProvider.call(application_choice)

      application_choice
    end
  end
end

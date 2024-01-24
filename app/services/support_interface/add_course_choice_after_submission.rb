module SupportInterface
  class AddCourseChoiceAfterSubmission
    attr_reader :application_form, :course_option

    def initialize(application_form:, course_option:)
      @application_form = application_form
      @course_option = course_option
    end

    def call
      ApplicationChoice.new(
        application_form:,
        status: 'unsubmitted',
      ).tap do |choice|
        choice.configure_initial_course_choice!(course_option)
        CandidateInterface::ContinuousApplications::SubmitApplicationChoice.new(choice).call
      end
    end
  end
end

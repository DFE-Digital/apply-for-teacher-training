module CandidateInterface
  module ContinuousApplications
    class ApplicationSubmitComponent < ViewComponent::Base
      attr_reader :application_choice, :submit_application_form
      delegate :unsubmitted?, :current_course, :current_course_option, to: :application_choice

      def initialize(application_choice:, submit_application_form:)
        @application_choice = application_choice
        @submit_application_form = submit_application_form
      end

      def application_can_submit?
        true
      end

      def error_messages
        []
        # govuk-body">You cannot submit this application until you’ve completed your details.</p>
        # <p class="govuk-body">You cannot submit this application now. You will be able to submit it from [date].</p>
        #
        # <p class="govuk-body">You cannot submit this application because there are no places left on the course.</p>
        # <p class="govuk-body">You need either to remove this application or change your course.</p>
      end
    end
  end
end

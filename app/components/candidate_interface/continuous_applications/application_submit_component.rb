module CandidateInterface
  module ContinuousApplications
    class ApplicationSubmitComponent < ViewComponent::Base
      include ApplicationHelper

      attr_reader :application_choice, :form, :submit_application_form, :application_choice_submission
      delegate :errors, to: :application_choice_submission
      delegate :unsubmitted?, :current_course, :current_course_option, to: :application_choice

      def initialize(application_choice:, form:)
        @application_choice = application_choice
        @form = form
        @submit_application_form = form.object
        @application_choice_submission = CandidateInterface::ContinuousApplications::ApplicationChoiceSubmission.new(application_choice:)
      end

      def render?
        unsubmitted?
      end

      def application_can_submit?
        @application_choice_submission.valid?
      end
    end
  end
end

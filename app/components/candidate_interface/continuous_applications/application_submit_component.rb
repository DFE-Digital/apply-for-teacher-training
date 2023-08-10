module CandidateInterface
  module ContinuousApplications
    class ApplicationSubmitComponent < ViewComponent::Base
      attr_reader :application_choice, :form, :submit_application_form, :application_form_presenter
      delegate :errors, to: :submit_application_form
      delegate :unsubmitted?, :current_course, :current_course_option, to: :application_choice

      def initialize(application_choice:, submit_application_form:, form:, application_can_submit:)
        @application_choice = application_choice
        @form = form
        @submit_application_form = submit_application_form
        @application_can_submit = application_can_submit
      end

      def application_can_submit?
        @application_can_submit.present?
      end
    end
  end
end

module CandidateInterface
  module ContinuousApplications
    class ApplicationSummaryComponent < ViewComponent::Base
      include CourseChoicesRowHelper
      attr_reader :application_choice
      delegate :unsubmitted?, :current_course, :current_course_option, :course_full?, to: :application_choice
      delegate :name_and_code, :description, :study_mode, :course_length, to: :current_course

      def initialize(application_choice:)
        @application_choice = application_choice
      end

      def rows
        [
          course_info_row,
          application_choice_status_row,
          rejection_reasons_row(application_choice),
          offer_withdrawal_reason_row(application_choice),
          interview_row(application_choice),
          ske_conditions_row(application_choice),
          reference_conditions_row(application_choice),
          conditions_row(application_choice),
          respond_to_offer_row(application_choice),
        ].compact
      end

      def title
        current_course.provider.name
      end

      def application_can_be_deleted?
        unsubmitted?
      end

      def application_can_be_withdrawn?
        withdrawable?(application_choice)
      end

      def container_class
        return unless @application_choice.course_full? && application_choice.unsubmitted?

        'govuk-inset-text app-inset-text--narrow-border app-inset-text--important govuk-!-padding-top-0 govuk-!-padding-bottom-0'
      end
    end
  end
end

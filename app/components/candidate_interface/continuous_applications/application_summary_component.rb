module CandidateInterface
  module ContinuousApplications
    class ApplicationSummaryComponent < ApplicationDashboardCourseChoicesComponent
      attr_reader :application_choice
      delegate :unsubmitted?, :current_course, :current_course_option, to: :application_choice
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
      alias application_is_unsubmitted? application_can_be_deleted?

      def application_can_be_withdrawn?
        withdrawable?(application_choice)
      end

    private

      def course_info_row
        {
          key: 'Course',
          value: [
            name_and_code,
            description,
            course_details,
          ],
        }
      end

      def course_details
        [
          DisplayCourseLength.call(course_length:),
          current_course_option.study_mode.humanize,
        ].compact.join(' ')
      end

      def application_choice_status_row
        {
          key: 'Status',
          value: render(ContinuousApplications::ApplicationStatusTagComponent.new(application_choice:)),
        }
      end
    end
  end
end

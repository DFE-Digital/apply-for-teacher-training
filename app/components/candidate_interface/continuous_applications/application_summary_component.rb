module CandidateInterface
  module ContinuousApplications
    class ApplicationSummaryComponent < ViewComponent::Base
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

      def withdrawable?(application_choice)
        ApplicationStateChange.new(application_choice).can_withdraw?
      end

      def application_can_be_withdrawn?
        withdrawable?(application_choice)
      end

      def container_class
        return unless @application_choice.course_full? && application_choice.unsubmitted?

        'govuk-inset-text app-inset-text--narrow-border app-inset-text--important govuk-!-padding-top-0 govuk-!-padding-bottom-0'
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
        }.tap do |row|
          if unsubmitted? && course_full?
            row[:action] = {
              href: candidate_interface_edit_continuous_applications_which_course_are_you_applying_to_path(application_choice.id),
              visually_hidden_text: "course for #{current_course.name_and_code}",
            }
          end
        end
      end

      def course_details
        [
          DisplayCourseLength.call(course_length:),
        ].compact.join(' ')
      end

      def application_choice_status_row
        {
          key: 'Status',
          value: render(ContinuousApplications::ApplicationStatusTagComponent.new(application_choice:)),
        }
      end

      def interview_row(application_choice)
        return unless application_choice.interviews.kept.any? || application_choice.decision_pending?

        {
          key: 'Interview'.pluralize(application_choice.interviews.size),
          value: render(InterviewBookingsComponent.new(application_choice)),
        }
      end

      def offer_withdrawal_reason_row(application_choice)
        return nil unless application_choice.offer_withdrawn?

        if application_choice.offer_withdrawal_reason.present?
          {
            key: 'Reason for offer withdrawal',
            value: application_choice.offer_withdrawal_reason,
          }
        end
      end

      def rejection_reasons_row(application_choice)
        return unless application_choice.rejected?
        return unless application_choice.rejection_reason.present? || application_choice.structured_rejection_reasons.present?

        {
          key: 'Feedback',
          value: render(
            RejectionsComponent.new(
              application_choice:,
              render_link_to_find_when_rejected_on_qualifications: @render_link_to_find_when_rejected_on_qualifications,
              rejection_reasons_component: CandidateInterface::RejectionReasons::RejectionReasonsComponent,
              feedback_button: true,
            ),
          ),
        }
      end

      def successful_application?(application_choice)
        application_choice.pending_conditions? || application_choice.offer? || application_choice.offer_deferred?
      end

      def ske_conditions_row(application_choice)
        return unless successful_application?(application_choice)
        return if (ske_conditions = application_choice.offer&.ske_conditions).blank?

        {
          key: 'Subject knowledge enhancement course'.pluralize(ske_conditions.size),
          value: render(OfferSkeConditionsReviewComponent.new(ske_conditions:)),
        }
      end

      def reference_conditions_row(application_choice)
        return unless successful_application?(application_choice)
        return if (reference_condition = application_choice.offer&.reference_condition).blank?

        {
          key: 'References',
          value: render(OfferReferenceConditionReviewComponent.new(reference_condition:)),
        }
      end

      def conditions_row(application_choice)
        return unless successful_application?(application_choice)
        return unconditional_offer_row if application_choice.unconditional_offer?

        {
          key: 'Condition'.pluralize(application_choice.offer.conditions.count),
          value: render(
            OfferConditionsReviewComponent.new(
              conditions: application_choice.offer.non_structured_conditions_text,
              provider: application_choice.current_course.provider.name,
              application_form: application_choice.application_form,
            ),
          ),
        }
      end

      def respond_to_offer_row(application_choice)
        return unless application_choice.offer?

        {
          key: ' ',
          value: render(
            CandidateInterface::CourseChoicesSummaryCardActionComponent.new(
              action: :respond_to_offer,
              application_choice:,
            ),
          ),
        }
      end
    end
  end
end

module CandidateInterface
  class RejectionReasonsComponent < ViewComponent::Base
    include ViewHelper

    def initialize(application_form:)
      @application_form = application_form
    end

    def application_choice_rows(application_choice)
      [
        course_details_row(application_choice),
        status_row(application_choice),
        rejection_reasons_row(application_choice),
      ].compact
    end

    def render?
      rejected_application_choices.present?
    end

  private

    def course_details_row(application_choice)
      {
        key: 'Course',
        value: course_details_row_value(application_choice),
      }
    end

    def course_details_row_value(application_choice)
      if CycleTimetable.find_down?
        tag.p(application_choice.current_course.name_and_code, class: 'govuk-!-margin-bottom-0') + tag.p(application_choice.course.description, class: 'govuk-body')
      else
        govuk_link_to(application_choice.current_course.name_and_code,
                      application_choice.current_course.find_url, target: '_blank', rel: 'noopener') +
          tag.p(application_choice.course.description, class: 'govuk-body')
      end
    end

    def status_row(application_choice)
      {
        key: 'Status',
        value: render(
          ApplicationStatusTagComponent.new(
            application_choice:,
            supplementary_statuses: supplementary_statuses_for(application_choice:),
          ),
        ),
      }
    end

    def rejection_reasons_row(application_choice)
      return unless application_choice.rejection_reason.present? || application_choice.structured_rejection_reasons.present? || application_choice.offer_withdrawal_reason.present?

      if application_choice.offer_withdrawn? && application_choice.offer_withdrawal_reason.present?
        {
          key: 'Feedback',
          value: application_choice.offer_withdrawal_reason,
        }
      else
        {
          key: 'Feedback',
          value: render(
            RejectionsComponent.new(
              application_choice:,
              render_link_to_find_when_rejected_on_qualifications: true,
              rejection_reasons_component: CandidateInterface::RejectionReasons::RejectionReasonsComponent,
            ),
          ),
        }
      end
    end

    def rejected_application_choices
      @rejected_application_choices ||=
        @application_form.application_choices
        .includes(
          :course,
          :provider,
          :current_course_option,
          :current_course,
        ).rejected.or(@application_form.application_choices.offer_withdrawn)
          .where.not(rejection_reason: nil).or(@application_form.application_choices.where.not(structured_rejection_reasons: nil)).or(@application_form.application_choices.where.not(offer_withdrawal_reason: nil))
    end
  end
end

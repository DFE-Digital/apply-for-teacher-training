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
      if EndOfCycleTimetable.find_down?
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
        value: render(ApplicationStatusTagComponent.new(application_choice: application_choice)),
      }
    end

    def rejection_reasons_row(application_choice)
      if application_choice.structured_rejection_reasons.present?
        {
          key: 'Feedback',
          value: render(
            ReasonsForRejectionComponent.new(
              application_choice: application_choice,
              reasons_for_rejection: ReasonsForRejection.new(application_choice.structured_rejection_reasons),
              editable: false,
              render_link_to_find_when_rejected_on_qualifications: true,
            ),
          ),
        }
      else
        {
          key: 'Feedback',
          value: application_choice.rejection_reason,
        }
      end
    end

    def rejected_application_choices
      @rejected_application_choices ||= begin
        rejected_applications = @application_form.application_choices.includes(:course, :provider, :current_course_option, :current_course).rejected
        rejected_applications = rejected_applications.where('application_choices.rejection_reason IS NOT NULL OR application_choices.structured_rejection_reasons IS NOT NULL')
        rejected_applications
      end
    end
  end
end

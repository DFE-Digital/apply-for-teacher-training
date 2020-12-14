module CandidateInterface
  class RejectionReasonsComponent < ViewComponent::Base
    include ViewHelper
    validates :application_form, presence: true

    def initialize(application_form:)
      @application_form = application_form
    end

    def application_choice_rows(application_choice)
      [
        course_details_row(application_choice),
        rejection_reasons_row(application_choice),
      ].compact
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
        tag.p(application_choice.offered_course.name_and_code, class: 'govuk-!-margin-bottom-0') + tag.p(application_choice.course.description, class: 'govuk-body')
      else
        govuk_link_to(application_choice.offered_course.name_and_code,
                      application_choice.offered_course.find_url, target: '_blank', rel: 'noopener') +
          tag.p(application_choice.course.description, class: 'govuk-body')
      end
    end

    def rejection_reasons_row(application_choice)
      if FeatureFlag.active?(:structured_reasons_for_rejection) && application_choice.structured_rejection_reasons.present?
        {
          key: 'Feedback',
          value: render(
            ReasonsForRejectionComponent.new(
              application_choice: application_choice,
              reasons_for_rejection: ReasonsForRejection.new(application_choice.structured_rejection_reasons),
              editable: false,
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
  end
end

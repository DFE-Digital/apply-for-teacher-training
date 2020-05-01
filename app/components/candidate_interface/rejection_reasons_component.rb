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
        value: govuk_link_to(application_choice.offered_course.name_and_code,
                             application_choice.offered_course.find_url, target: '_blank', rel: 'noopener') +
          content_tag(:p, application_choice.course.description, class: 'govuk-body'),
      }
    end

    def rejection_reasons_row(application_choice)
      {
        key: 'Reasons for rejection',
        value: application_choice.rejection_reason,
      }
    end
  end
end

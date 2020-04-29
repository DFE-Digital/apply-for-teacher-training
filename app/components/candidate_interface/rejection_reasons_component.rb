module CandidateInterface
  class RejectionReasonsComponent < ViewComponent::Base
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
        value: application_choice.course.name_code_and_description,
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

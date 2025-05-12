module CandidateInterface
  class ApplicationChoiceSubmission
    include ActiveModel::Model
    include GovukVisuallyHiddenHelper

    attr_accessor :application_choice

    delegate :application_form, to: :application_choice
    validates :application_choice,
              immigration_status: true,
              applications_closed: { if: :validate_choice? },
              course_unavailable: { if: :validate_choice? },
              incomplete_primary_course_details: { if: :validate_choice? },
              incomplete_postgraduate_course_details: { if: :validate_choice? },
              incomplete_undergraduate_course_details: { if: :validate_choice? },
              incomplete_details: { if: :validate_choice? },
              visa_sponsorship_application_deadline_passed: { if: :validate_choice? },
              can_add_more_choices: true

  private

    def validate_choice?
      errors.exclude?(:application_choice)
    end
  end
end

module CandidateInterface
  class ReferenceSectionCompleteForm < SectionCompleteForm
    attr_accessor :application_form

    validates :application_form, application_form_with_complete_references: true, if: :completed?
  end
end

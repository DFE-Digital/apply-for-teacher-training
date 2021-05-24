module CandidateInterface
  class UnsubmittedReferenceReviewComponent < SummaryListComponent
    def initialize(reference:)
      @reference = reference
    end

    def rows
      [
        name_row(reference),
        email_address_row(reference),
        type_row(reference),
        relationship_row(reference),
      ]
    end

  private

    attr_reader :reference

    def name_row(reference)
      {
        key: 'Name',
        value: reference.name,
        action: "name for #{reference.name}",
        change_path: candidate_interface_references_edit_name_path(reference.id),
      }
    end

    def email_address_row(reference)
      {
        key: 'Email address',
        value: reference.email_address,
        action: "email address for #{reference.name}",
        change_path: candidate_interface_references_edit_email_address_path(reference.id),
      }
    end

    def type_row(reference)
      {
        key: 'Reference type',
        value: reference.referee_type ? reference.referee_type.capitalize.dasherize : '',
        action: "reference type for #{reference.name}",
        change_path: candidate_interface_references_edit_type_path(reference.referee_type, reference.id),
      }
    end

    def relationship_row(reference)
      {
        key: 'Relationship to referee',
        value: reference.relationship,
        action: "relationship for #{reference.name}",
        change_path: candidate_interface_references_edit_relationship_path(reference.id),
      }
    end
  end
end

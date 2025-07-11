module CandidateInterface
  class Reference::RefereeRelationshipForm
    include ActiveModel::Model

    attr_accessor :relationship

    validates :relationship, presence: true, length: { maximum: 500 }

    def self.build_from_reference(reference)
      new(relationship: reference.relationship)
    end

    def save(reference)
      return false unless valid?

      application_form = reference.application_form

      ApplicationForm.with_unsafe_application_choice_touches do
        reference.update!(relationship:)
        application_form.update!(references_completed: true) if application_form.successful?
        true
      end
    end
  end
end

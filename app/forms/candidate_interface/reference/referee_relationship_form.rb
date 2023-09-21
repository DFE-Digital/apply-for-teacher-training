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

      ApplicationForm.with_unsafe_application_choice_touches do
        reference.update!(relationship:)
      end
    end
  end
end

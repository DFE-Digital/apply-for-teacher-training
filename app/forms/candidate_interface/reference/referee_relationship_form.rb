module CandidateInterface
  class Reference::RefereeRelationshipForm
    include ActiveModel::Model

    attr_accessor :relationship

    validates :relationship, presence: true

    def self.build_from_reference(reference)
      new(relationship: reference.relationship)
    end

    def save(reference)
      return false unless valid?

      reference.update!(relationship: relationship)
    end
  end
end

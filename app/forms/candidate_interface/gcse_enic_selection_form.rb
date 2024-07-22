module CandidateInterface
  class GcseEnicSelectionForm
    include ActiveModel::Model

    attr_accessor :enic_reason, :enic_reference, :comparable_uk_qualification

    validates :enic_reason, presence: true

    def self.build_from_qualification(qualification)
      new(
        enic_reason: qualification.enic_reason,
        enic_reference: qualification.enic_reference,
        comparable_uk_qualification: qualification.comparable_uk_qualification,
      )
    end

    def save(qualification)
      return false unless valid?

      qualification.update!(
        enic_reason: enic_reason,
        enic_reference: enic_reference,
        comparable_uk_qualification: comparable_uk_qualification,
      )
    end
  end
end

module CandidateInterface
  class GcseEnicSelectionForm
    include ActiveModel::Model

    attr_accessor :have_enic_reference, :enic_reference, :comparable_uk_qualification

    validates :have_enic_reference, presence: true

    def self.build_from_qualification(qualification)
      new(
        have_enic_reference: qualification.enic_reason,
        enic_reference: qualification.enic_reference,
        comparable_uk_qualification: qualification.comparable_uk_qualification,
      )
    end

    def save(qualification)
      return false unless valid?

      qualification.update!(
        enic_reason: have_enic_reference,
        enic_reference: enic_reference,
        comparable_uk_qualification: comparable_uk_qualification,
      )
    end
  end
end

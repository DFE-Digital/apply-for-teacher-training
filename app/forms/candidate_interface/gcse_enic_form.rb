module CandidateInterface
  class GcseEnicForm
    include ActiveModel::Model

    attr_accessor :enic_reference, :comparable_uk_qualification

    validates :enic_reference, presence: true
    validates :comparable_uk_qualification, presence: true

    def self.build_from_qualification(qualification)
      new(
        enic_reference: qualification.enic_reference,
        comparable_uk_qualification: qualification.comparable_uk_qualification,
      )
    end

    def save(qualification)
      return false unless valid?

      qualification.update!(
        enic_reference: enic_reference,
        comparable_uk_qualification: comparable_uk_qualification,
      )
    end
  end
end

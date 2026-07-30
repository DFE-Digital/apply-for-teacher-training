module CandidateInterface
  class GcseEnicSelectionForm
    include ActiveModel::Model

    attr_accessor :enic_reason

    validates :enic_reason, presence: true

    def self.build_from_qualification(qualification)
      new(
        enic_reason: qualification.enic_reason,
      )
    end

    def save(qualification)
      return false unless valid?

      attrs = { enic_reason: enic_reason }

      if enic_reason != 'obtained'
        attrs.merge!(
          enic_reference: nil,
          comparable_uk_qualification: nil,
        )
      end

      qualification.update!(attrs)
    end
  end
end

module CandidateInterface
  class GcseEnicForm
    include ActiveModel::Model

    attr_accessor :have_enic_reference, :enic_reference, :comparable_uk_qualification

    validates :have_enic_reference, presence: true

    validates :enic_reference, :comparable_uk_qualification, presence: true, if: :chose_to_provide_enic_reference?

    def self.build_from_qualification(qualification)
      new(
        have_enic_reference: qualification.have_enic_reference,
        enic_reference: qualification.enic_reference,
        comparable_uk_qualification: qualification.comparable_uk_qualification,
      )
    end

    def save(qualification)
      return false unless valid?

      qualification.update!(
        enic_reference: enic_reference,
        naric_reference: enic_reference,
        comparable_uk_qualification: comparable_uk_qualification,
      )
    end

    def set_attributes(params)
      @have_enic_reference = params['have_enic_reference']
      @enic_reference = chose_to_provide_enic_reference? ? params['enic_reference'] : nil
      @comparable_uk_qualification = chose_to_provide_enic_reference? ? params['comparable_uk_qualification'] : nil
    end

  private

    def chose_to_provide_enic_reference?
      have_enic_reference == 'Yes'
    end
  end
end

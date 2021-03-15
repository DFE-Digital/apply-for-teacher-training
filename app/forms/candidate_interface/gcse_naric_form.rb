module CandidateInterface
  class GcseNaricForm
    include ActiveModel::Model

    attr_accessor :have_naric_reference, :naric_reference, :comparable_uk_qualification

    validates :have_naric_reference, presence: true

    validates :naric_reference, :comparable_uk_qualification, presence: true, if: :chose_to_provide_naric_reference?

    def self.build_from_qualification(qualification)
      new(
        have_naric_reference: qualification.have_naric_reference,
        naric_reference: qualification.naric_reference,
        comparable_uk_qualification: qualification.comparable_uk_qualification,
      )
    end

    def save(qualification)
      return false unless valid?

      qualification.update!(
        naric_reference: naric_reference,
        enic_reference: naric_reference,
        comparable_uk_qualification: comparable_uk_qualification,
      )
    end

    def set_attributes(params)
      @have_naric_reference = params['have_naric_reference']
      @naric_reference = chose_to_provide_naric_reference? ? params['naric_reference'] : nil
      @comparable_uk_qualification = chose_to_provide_naric_reference? ? params['comparable_uk_qualification'] : nil
    end

  private

    def chose_to_provide_naric_reference?
      have_naric_reference == 'Yes'
    end
  end
end

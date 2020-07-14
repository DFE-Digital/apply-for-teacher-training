module CandidateInterface
  class NaricReferenceForm
    include ActiveModel::Model

    attr_accessor :naric_reference_choice, :naric_reference, :comparable_uk_qualification

    validates :naric_reference_choice, presence: true

    validates :naric_reference, :comparable_uk_qualification, presence: true, if: :chose_to_provide_naric_reference?

    def self.build_from_qualification(qualification)
      new(
        naric_reference: qualification.naric_reference,
        naric_reference_choice: qualification.naric_reference_choice,
        comparable_uk_qualification: qualification.comparable_uk_qualification,
      )
    end

    def save(qualification)
      return false unless valid?

      qualification.update!(
        naric_reference: naric_reference,
        comparable_uk_qualification: comparable_uk_qualification,
      )
    end

  private

    def chose_to_provide_naric_reference?
      naric_reference_choice == 'Yes'
    end

    def set_attributes(params)
      @naric_reference_choice = params['naric_reference_choice']
      @naric_reference = params['naric_reference']
      @comparable_uk_qualification = params['comparable_uk_qualification']
    end
  end
end

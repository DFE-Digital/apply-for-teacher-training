module CandidateInterface
  class NaricReferenceForm
    include ActiveModel::Model

    attr_accessor :naric_reference_choice, :naric_reference, :comparable_uk_qualification

    validates :naric_reference_choice, presence: true

    validates :naric_reference, :comparable_uk_qualification, presence: true, if: :chose_to_provide_naric_reference?

    def chose_to_provide_naric_reference?
      naric_reference_choice == 'Yes'
    end
  end
end

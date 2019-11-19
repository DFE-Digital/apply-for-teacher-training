module CandidateInterface
  class EligibilityForm
    include ActiveModel::Model

    attr_accessor :eligible_citizen, :eligible_qualifications
    validates :eligible_citizen, :eligible_qualifications, presence: true

    def eligible_to_use_dfe_apply?
      eligible_citizen == 'yes' &&
        eligible_qualifications == 'yes'
    end
  end
end

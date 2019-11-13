module CandidateInterface
  class EligibilityForm
    attr_accessor :eligible_citizen, :eligible_qualifications, :eligible_providers
    include ActiveModel::Model

    def eligible_to_use_dfe_apply?
      eligible_citizen == 'yes' &&
        eligible_qualifications == 'yes' &&
        eligible_providers == 'yes'
    end
  end
end

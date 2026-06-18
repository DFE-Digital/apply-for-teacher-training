module CandidateInterface
  class GcseInternationalEvidenceForm
    include ActiveModel::Model

    attr_accessor :evidence

    validates :evidence, presence: true
    validates :evidence, length: { minimum: 10, maximum: 400 }

    def self.build_from_qualification(application_qualification)
      new(
        evidence: application_qualification.missing_explanation,
        # TODO: Check this is the correct field to store this data
      )
    end

    def save(application_qualification)
      return false unless valid?

      application_qualification.update!(
        missing_explanation: evidence,
      )
    end
  end
end

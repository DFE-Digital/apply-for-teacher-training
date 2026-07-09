module CandidateInterface
  class GcseInternationalEvidenceForm
    include ActiveModel::Model

    attr_accessor :evidence, :subject

    validate :evidence_presence
    validates :evidence, length: { maximum: 500 }

    def self.build_from_qualification(application_qualification, subject:)
      new(
        evidence: application_qualification.not_completed_explanation,
        subject:,
      )
    end

    def save(application_qualification)
      return false unless valid?

      application_qualification.update!(
        not_completed_explanation: evidence,
      )
    end

    def evidence_presence
      return if evidence.present?

      errors.add(:evidence, "Enter evidence that your #{subject == 'english' ? subject.capitalize : subject} skills are at GCSE grade 4 (C) or above")
    end
  end
end

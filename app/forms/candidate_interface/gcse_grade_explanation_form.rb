module CandidateInterface
  class GcseGradeExplanationForm
    include ActiveModel::Model

    attr_accessor :missing_explanation, :not_completed_explanation

    validate :validates_not_completed_explanation

    def self.build_from_qualification(qualification)
      new(
        missing_explanation: qualification.missing_explanation,
        not_completed_explanation: qualification.not_completed_explanation,
      )
    end

    def save(qualification)
      @subject_name = qualification.subject == 'english' ? qualification.subject.capitalize : qualification.subject
      return false unless valid?

      qualification.update!(
        missing_explanation: missing_explanation,
        not_completed_explanation: not_completed_explanation,
      )
    end

  private

    def validates_not_completed_explanation
      errors.add(:not_completed_explanation, :blank, subject: @subject_name) if not_completed_explanation.blank?
    end
  end
end

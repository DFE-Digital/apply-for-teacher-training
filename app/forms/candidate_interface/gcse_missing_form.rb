module CandidateInterface
  class GcseMissingForm
    include ActiveModel::Model
    include GcseQualificationHelper

    attr_accessor :missing_explanation, :not_completed_explanation, :level, :subject, :qualification_type

    validates :missing_explanation, word_count: { maximum: 50 }
    validate :missing_explanation_presence

    def self.build_from_qualification(qualification)
      new(
        level: qualification.level,
        subject: qualification.subject,
        qualification_type: qualification.qualification_type,
        missing_explanation: qualification.missing_explanation,
      )
    end

    def save(qualification)
      return false unless valid?

      if qualification_type == 'missing'

        qualification.update!(
          missing_explanation:,
          grade: nil,
          award_year: nil,
          institution_name: nil,
          institution_country: nil,
          start_year: nil,
        )
      else
        qualification.update!(missing_explanation:)
      end
    end

  private

    def missing_explanation_presence
      if missing_explanation.blank?
        errors.add(:missing_explanation, :blank, subject: capitalize_english(@subject))
      end
    end
  end
end

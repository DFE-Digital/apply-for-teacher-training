module CandidateInterface
  class GcseNotCompletedForm
    include ActiveModel::Model

    attr_accessor :not_completed_explanation, :choice, :level, :subject, :qualification_type

    validates :not_completed_explanation, presence: true, if: -> { choice == 'yes' }

    validates :not_completed_explanation, word_count: { maximum: 200 }
    validates :choice, presence: true

    def self.build_from_qualification(qualification)
      new(
        level: qualification.level,
        subject: qualification.subject,
        qualification_type: qualification.qualification_type,
        not_completed_explanation: qualification.not_completed_explanation,
      )
    end

    def save(qualification)
      return false unless valid?

      qualification.update!(
        not_completed_explanation: choice == 'yes' ? not_completed_explanation : nil,
        missing_explanation: nil,
        grade: nil,
        award_year: nil,
        institution_name: nil,
        institution_country: nil,
        start_year: nil,
      )
    end
  end
end

module CandidateInterface
  class GcseNotCompletedForm
    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks

    attr_accessor :not_completed_explanation, :currently_completing_qualification, :level, :subject, :qualification_type

    before_validation :cast_currently_completing_qualification

    validates :not_completed_explanation, presence: true, if: -> { currently_completing_qualification }

    validates :not_completed_explanation, length: { maximum: 256 }
    validate :validates_currently_completing_qualification

    def self.build_from_qualification(qualification)
      new(
        level: qualification.level,
        subject: qualification.subject,
        qualification_type: qualification.qualification_type,
        not_completed_explanation: qualification.not_completed_explanation,
        currently_completing_qualification: qualification.currently_completing_qualification,
      )
    end

    def save(qualification)
      @subject_name = qualification.subject == 'english' ? qualification.subject.capitalize : qualification.subject

      return false unless valid?

      qualification.update!(
        not_completed_explanation: currently_completing_qualification ? not_completed_explanation : nil,
        missing_explanation: nil,
        grade: nil,
        award_year: nil,
        institution_name: nil,
        institution_country: nil,
        start_year: nil,
        currently_completing_qualification:,
      )
    end

  private

    def validates_currently_completing_qualification
      errors.add(:currently_completing_qualification, :inclusion, subject: @subject_name) unless currently_completing_qualification.in? [true, false]
    end

    def cast_currently_completing_qualification
      self.currently_completing_qualification = ActiveModel::Type::Boolean.new.cast(currently_completing_qualification)
    end
  end
end

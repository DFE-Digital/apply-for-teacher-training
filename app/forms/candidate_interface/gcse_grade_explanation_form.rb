module CandidateInterface
  class GcseGradeExplanationForm
    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks

    attr_accessor :currently_completing_qualification, :missing_explanation

    before_validation :cast_currently_completing_qualification

    validate :validates_not_completed_explanation

    def self.build_from_qualification(qualification)
      new(
        currently_completing_qualification: qualification.currently_completing_qualification,
        missing_explanation: qualification.missing_explanation,
      )
    end

    def save(qualification)
      @subject_name = qualification.subject == 'english' ? qualification.subject.capitalize : qualification.subject
      return false unless valid?

      qualification.update!(
        currently_completing_qualification: currently_completing_qualification,
        missing_explanation: currently_completing_qualification ? nil : missing_explanation,
      )
    end

  private

    def validates_not_completed_explanation
      errors.add(:currently_completing_qualification, :blank, subject: @subject_name) unless [true, false].include?(currently_completing_qualification)
    end

    def cast_currently_completing_qualification
      self.currently_completing_qualification = ActiveModel::Type::Boolean.new.cast(currently_completing_qualification)
    end
  end
end

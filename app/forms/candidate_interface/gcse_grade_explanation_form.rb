module CandidateInterface
  class GcseGradeExplanationForm
    include ActiveModel::Model

    attr_accessor :missing_explanation

    def self.build_from_qualification(qualification)
      new(
        missing_explanation: qualification.missing_explanation,
      )
    end

    def save(qualification)
      return false unless valid?

      qualification.update!(missing_explanation: missing_explanation)
    end
  end
end

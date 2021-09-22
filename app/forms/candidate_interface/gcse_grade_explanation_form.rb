module CandidateInterface
  class GcseGradeExplanationForm
    include ActiveModel::Model

    attr_accessor :not_completed_explanation

    def self.build_from_qualification(qualification)
      new(
        not_completed_explanation: qualification.not_completed_explanation,
      )
    end

    def save(qualification)
      return false unless valid?

      qualification.update!(not_completed_explanation: not_completed_explanation)
    end
  end
end

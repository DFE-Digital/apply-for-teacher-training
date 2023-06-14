module CandidateInterface
  class EqualityAndDiversityCompleteForm < SectionCompleteForm
    attr_accessor :current_application
    delegate :equality_and_diversity_answers_provided?, to: :current_application
    validate :verify_incomplete_answers, if: :completed?

    def verify_incomplete_answers
      errors.add(:completed, :incomplete_answers) unless equality_and_diversity_answers_provided?
    end
  end
end

module RefereeInterface
  class ReferenceReviewForm
    include ActiveModel::Model

    attr_reader :reference

    def initialize(reference:)
      @reference = reference
    end

    validate :questions_complete

    def questions_complete
      if reference.feedback.nil? || reference.safeguarding_concerns.nil? || reference.relationship_correction.nil?
        errors.add(:base, 'Can\'t submit a reference without answers to all questions')
      end
    end
  end
end

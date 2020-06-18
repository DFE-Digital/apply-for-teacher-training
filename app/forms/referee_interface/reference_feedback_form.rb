module RefereeInterface
  class ReferenceFeedbackForm
    include ActiveModel::Validations
    attr_reader :reference, :feedback
    validates :feedback, presence: true, word_count: { maximum: 300 }
    delegate :application_form, to: :reference

    def initialize(reference:, feedback:)
      @reference = reference
      @feedback = feedback
    end

    def save
      return unless valid?

      reference.update!(feedback: feedback)
      true
    end
  end
end

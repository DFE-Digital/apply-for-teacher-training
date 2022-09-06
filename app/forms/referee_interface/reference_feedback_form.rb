module RefereeInterface
  class ReferenceFeedbackForm
    include ActiveModel::Validations
    attr_reader :reference, :feedback
    validates :feedback, presence: true, word_count: { maximum: 500 }
    delegate :application_form, to: :reference

    def initialize(reference:, feedback:)
      @reference = reference
      @feedback = feedback
    end

    def save
      return unless valid?

      reference.update!(feedback:)
      true
    end
  end
end

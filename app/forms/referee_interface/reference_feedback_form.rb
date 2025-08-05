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

      ApplicationForm.with_unsafe_application_choice_touches do
        reference.update!(feedback:)
      end

      true
    end
  end
end

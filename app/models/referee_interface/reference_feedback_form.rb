module RefereeInterface
  class ReferenceFeedbackForm
    include ActiveModel::Validations

    attr_reader :reference, :feedback
    validates :feedback, presence: true, word_count: { maximum: 300 }

    def initialize(reference:, feedback: nil)
      @reference = reference
      @feedback = feedback
    end

    def save
      return unless valid?

      if FeatureFlag.active?('referee_confirm_relationship_and_safeguarding')
        reference.update!(feedback: feedback)
      else
        ReceiveReference.new(
          reference: reference,
          feedback: feedback,
        ).save!
      end

      true
    end
  end
end

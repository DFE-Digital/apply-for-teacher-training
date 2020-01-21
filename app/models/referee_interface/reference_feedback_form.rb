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

      ActiveRecord::Base.transaction do
        ReceiveReference.new(
          application_form: reference.application_form,
          referee_email: reference.email_address,
          feedback: feedback,
        ).save
      end
    end
  end
end

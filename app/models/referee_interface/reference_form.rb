module RefereeInterface
  class ReferenceForm
    include ActiveModel::Model

    attr_accessor :feedback

    validates :feedback,
              word_count: { maximum: 300 },
              presence: true

    def self.build_from_reference(reference)
      new(
        feedback: reference.feedback,
        )
    end

    def save(reference)
      return false unless valid?

      reference.update!(feedback: feedback)
      true
    end
  end
end

module SupportInterface
  class BlockSubmissionForm
    include ActiveModel::Model

    attr_accessor :accept_guidance

    validates :accept_guidance, presence: true

    def save(fraud_match_id)
      self.accept_guidance = ActiveModel::Type::Boolean.new.cast(accept_guidance)

      return false unless valid?

      FraudMatch.find(fraud_match_id).update!(blocked: true, fraudulent?: true)
    end
  end
end

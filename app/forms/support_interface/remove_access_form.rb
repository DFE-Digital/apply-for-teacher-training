module SupportInterface
  class RemoveAccessForm
    include ActiveModel::Model

    attr_accessor :accept_guidance

    validates :accept_guidance, presence: true

    def save(candidate)
      self.accept_guidance = ActiveModel::Type::Boolean.new.cast(accept_guidance)

      return false unless valid?

      email_address = "fraud-match-id-#{candidate.fraud_match.id}-candidate-id-#{candidate.id}-#{candidate.email_address}"

      candidate.update!(email_address: email_address)
    end
  end
end

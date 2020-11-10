module ProviderInterface
  class RejectedByDefaultFeedbackForm
    include ActiveModel::Model

    attr_accessor :rejection_reason
    validates :rejection_reason, presence: true

    validate :rejection_reason do |record|
      if record.rejection_reason && record.rejection_reason.scan(/\w+/).length > 200
        record.errors.add(:rejection_reason, :too_long)
      end
    end
  end
end

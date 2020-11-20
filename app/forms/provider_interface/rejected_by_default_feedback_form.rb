module ProviderInterface
  class RejectedByDefaultFeedbackForm
    include ActiveModel::Model

    attr_accessor :rejection_reason
    validates :rejection_reason, presence: true
    validates :rejection_reason, word_count: { maximum: 200 }
  end
end

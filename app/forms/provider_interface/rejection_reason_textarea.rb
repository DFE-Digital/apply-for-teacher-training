module ProviderInterface
  class RejectionReasonTextarea
    include ActiveModel::Model

    attr_accessor :label
    attr_accessor :value

    validates :value, presence: true
  end
end

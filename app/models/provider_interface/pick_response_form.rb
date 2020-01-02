module ProviderInterface
  class PickResponseForm
    include ActiveModel::Model

    attr_accessor :decision
    validates :decision, presence: true
  end
end

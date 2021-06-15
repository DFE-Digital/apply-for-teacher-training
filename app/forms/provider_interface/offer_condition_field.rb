module ProviderInterface
  class OfferConditionField
    include ActiveModel::Model

    attr_accessor :id, :text, :condition_id

    validates :text, length: { maximum: 255, too_long: ->(c, _) { "Condition #{c.id + 1} must be %{count} characters or fewer" } }
  end
end

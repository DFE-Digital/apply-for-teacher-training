class TextCondition < OfferCondition
  detail :description

  validates :description, presence: true

  def initialize(attrs = {})
    attrs ||= {}
    super({ status: :pending }.merge(attrs))
  end

  def text
    description
  end

  def text=(value)
    self.description = value
  end
end

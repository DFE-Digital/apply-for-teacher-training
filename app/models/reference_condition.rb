class ReferenceCondition < OfferCondition
  detail :required
  detail :description

  def initialize(attrs = {})
    attrs ||= {}
    super({ status: :pending }.merge(attrs))
  end

  def text
    'Specific references'
  end
end

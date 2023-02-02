class SkeCondition < OfferCondition
  detail :language
  detail :length
  detail :reason

  validates :language, presence: true, on: :language
  validates :length, presence: true, on: :length
  validates :reason, presence: true, on: :reason

  attr_accessor :required
end

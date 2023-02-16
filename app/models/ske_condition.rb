class SkeCondition < OfferCondition
  detail :language
  detail :length
  detail :reason

  VALID_LANGUAGES = [
    'French',
    'Spanish',
    'German',
    'ancient languages',
  ].freeze

  validates :language, inclusion: { in: VALID_LANGUAGES }, allow_blank: false, on: :language
  validates :length, presence: true, on: :length
  validates :reason, presence: true, on: :reason

  attr_accessor :required
end

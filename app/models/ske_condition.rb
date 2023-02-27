class SkeCondition < OfferCondition
  detail :graduation_cutoff_date
  detail :length
  detail :reason
  detail :subject
  detail :subject_type

  VALID_LANGUAGES = [
    'French',
    'Spanish',
    'German',
    'ancient languages',
  ].freeze

  validates :graduation_cutoff_date, presence: true, if: :outdated_degree?
  validates :length, presence: true, on: :length
  validates :reason, presence: true, on: :reason
  validates :status, inclusion: { in: %w[met unmet] }
  validates :subject, inclusion: { in: VALID_LANGUAGES }, allow_blank: false, on: :subject, if: :language_subject?
  validates :subject, presence: true, on: :subject, if: :standard_subject?

  attr_accessor :required

  def initialize(attrs = {})
    attrs ||= {}
    super({ status: :unmet }.merge(attrs))
  end

  def language_subject?
    subject_type == 'language'
  end

  def standard_subject?
    subject_type == 'standard'
  end

  def outdated_degree?
    reason == 'outdated_degree'
  end
end

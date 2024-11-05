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

  VALID_REASONS = [
    DIFFERENT_DEGREE_REASON = 'different_degree'.freeze,
    OUTDATED_DEGREE_REASON = 'outdated_degree'.freeze,
  ].freeze

  MAX_SKE_LANGUAGES = 2
  MAX_SKE_LENGTH = 36

  SKE_LENGTHS = 8.step(by: 4).take(6).freeze

  validates :graduation_cutoff_date, presence: true, if: :outdated_degree?
  validates :length, presence: true, on: :length
  validates :reason, presence: true, on: :reason
  validates :reason, inclusion: { in: VALID_REASONS }, allow_nil: true
  validates :status, inclusion: { in: %w[pending met unmet] }
  validates :subject, inclusion: { in: VALID_LANGUAGES }, allow_blank: false, on: :subject, if: :language_subject?
  validates :subject, presence: true, on: :subject, if: :standard_subject?
  validate :length_for_ske_courses

  attr_accessor :required

  def initialize(attrs = {})
    attrs ||= {}
    super({ status: :pending }.merge(attrs))
  end

  def self.no_conditions_meet_minimum_length_criteria?(ske_conditions)
    ske_conditions.many? && ske_conditions.none? { |sc| sc.length == SKE_LENGTHS.first.to_s }
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

  def text
    "#{subject} subject knowledge enhancement course"
  end

  def length_for_ske_courses
    return if length.blank?

    if SKE_LENGTHS.exclude?(length.to_i)
      errors.add(
        :length,
        :invalid_length,
        allowed_values: SkeCondition::SKE_LENGTHS.to_sentence(last_word_connector: ' or '),
      )
    end
  end

  def subject_code
    subject = offer&.course_option&.course&.subjects&.first # rubocop:disable Style/SafeNavigationChainLength
    subject&.code
  end
end

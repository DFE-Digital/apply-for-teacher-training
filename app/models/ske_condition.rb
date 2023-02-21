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
  validates :subject, inclusion: { in: VALID_LANGUAGES }, allow_blank: false, on: :subject, if: :language_subject?
  validates :subject, presence: true, on: :subject, if: :standard_subject?

  attr_accessor :required

  def language_subject?
    subject_type == 'language'
  end

  def standard_subject?
    subject_type == 'standard'
  end

  def outdated_degree?
    reason == 'outdated_degree'
  end

  def formatted_cutoff_date
    return if graduation_cutoff_date.blank?

    Date.parse(graduation_cutoff_date).to_fs(:month_and_year)
  end

  def formatted_reason(interface)
    return if reason.blank?

    I18n.t(
      "#{interface}.offer.ske_reasons.#{reason}",
      degree_subject: subject,
      graduation_cutoff_date: formatted_cutoff_date,
    )
  end

  def course_description
    # e.g.
    # a 12 week French course
    # an 8 week Mathematics course
    [
      (length == '8' ? 'an' : 'a'),
      length,
      'week',
      subject,
      'course',
    ].join(' ')
  end
end

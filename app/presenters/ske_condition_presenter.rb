class SkeConditionPresenter
  delegate :length, :subject, :graduation_cutoff_date, to: :record

  def initialize(record, interface: nil)
    @record = record
    @interface = interface
  end

  def reason(interface = nil)
    return if record.reason.blank?

    I18n.t(
      "#{interface || @interface}.offer.ske_reasons.#{record.reason}",
      degree_subject: subject,
      graduation_cutoff_date: cutoff_date,
    )
  end

  def cutoff_date
    return if graduation_cutoff_date.blank?

    Date.parse(graduation_cutoff_date).to_fs(:month_and_year)
  end

  def course_description(determiner: true)
    # e.g.
    # a 12 week French course
    # an 8 week Mathematics course
    [
      ((length == '8' ? 'an' : 'a') if determiner),
      length,
      'week',
      subject,
      'course',
    ].compact_blank.join(' ')
  end

private

  attr_reader :record
end

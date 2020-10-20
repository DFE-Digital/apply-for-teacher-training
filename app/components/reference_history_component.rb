class ReferenceHistoryComponent < ViewComponent::Base
  attr_reader :reference

  def initialize(reference)
    @reference = reference
  end

  def history
    reference.reference_events.order(created_at: :asc)
  end

  def event_title(event)
    case event.name
    when 'request_sent'
      'Request sent'
    when 'request_cancelled'
      'Request cancelled'
    when 'reminder_sent'
      'Reminder sent'
    end
  end

  def requested_at
    return if reference.requested_at.blank?

    date_format(reference.requested_at)
  end

  def reminder_sent_at
    return if reference.reminder_sent_at.blank?

    date_format(reference.reminder_sent_at)
  end

  def date_format(datetime)
    datetime.to_s(:govuk_date_and_time)
  end
end

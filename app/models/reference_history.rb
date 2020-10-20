class ReferenceHistory
  Event = Struct.new(:name, :time)

  attr_reader :reference

  def initialize(reference)
    @reference = reference
  end

  def all_events
    request_sent_events.concat(
      request_cancelled_events.concat(
        reminder_sent_events,
      ),
    ).sort_by(&:time)
  end

  def request_sent_events
    audits
      .select { |a| a.audited_changes['feedback_status']&.second == 'feedback_requested' }
      .map { |a| Event.new('request_sent', a.created_at) }
  end

  def request_cancelled_events
    audits
      .select { |a| a.audited_changes['feedback_status']&.second == 'cancelled' }
      .map { |a| Event.new('request_cancelled', a.created_at) }
  end

  def reminder_sent_events
    audits
      .select { |a| a.audited_changes['reminder_sent_at'].present? }
      .map { |a| Event.new('reminder_sent', a.created_at) }
  end

private

  def audits
    reference.audits.updates
  end
end

class ReferenceHistory
  Event = Struct.new(:name, :time, :extra_info)

  attr_reader :reference

  def initialize(reference)
    @reference = reference
  end

  def all_events
    request_sent
      .concat(request_cancelled)
      .concat(reminder_sent)
      .concat(request_bounced)
      .concat(request_declined)
      .concat(reference_received)
      .concat(automated_reminder_sent)
      .sort_by(&:time)
  end

  def request_sent
    audits
      .select { |a| status_change(a, to: 'feedback_requested') }
      .map do |audit|
        email_address = reference.revision(audit.version).email_address
        Event.new('request_sent', audit.created_at, OpenStruct.new(email_address: email_address))
      end
  end

  def request_cancelled
    audits
      .select { |a| status_change(a, to: 'cancelled') || status_change(a, to: 'cancelled_at_end_of_cycle') }
      .map { |a| Event.new('request_cancelled', a.created_at) }
  end

  def reminder_sent
    audits
      .select { |a| a.audited_changes['reminder_sent_at'].present? }
      .map { |a| Event.new('reminder_sent', a.created_at) }
  end

  def request_bounced
    audits
      .select { |a| status_change(a, to: 'email_bounced') }
      .map do |audit|
        bounced_email = reference.revision(audit.version).email_address
        Event.new('request_bounced', audit.created_at, OpenStruct.new(bounced_email: bounced_email))
      end
  end

  def request_declined
    audits
      .select { |a| status_change(a, to: 'feedback_refused') }
      .map { |a| Event.new('request_declined', a.created_at) }
  end

  def reference_received
    audits
      .select { |a| status_change(a, to: 'feedback_provided') }
      .map { |a| Event.new('reference_received', a.created_at) }
  end

  def automated_reminder_sent
    chasers
      .reference_request.or(chasers.follow_up_missing_references)
      .map { |c| Event.new('automated_reminder_sent', c.created_at) }
  end

private

  def audits
    @audits ||= reference.audits.updates
  end

  def chasers
    @chasers ||= reference.chasers_sent
  end

  def status_change(audit, to:)
    audit.audited_changes['feedback_status']&.second == to
  end
end

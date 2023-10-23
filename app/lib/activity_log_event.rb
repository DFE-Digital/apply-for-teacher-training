class ActivityLogEvent
  attr_reader :audit
  delegate :user, :created_at, to: :audit

  def initialize(audit:)
    @audit = audit
  end

  def application_choice
    return audit.auditable if audit.auditable.is_a?(ApplicationChoice)
    return audit.associated if audit.auditable.is_a?(Interview)

    ApplicationChoice.find(audit.application_choice_id)
  end

  def changes
    audit.audited_changes
  end

  def user_full_name
    user.try(:full_name) || user.try(:display_name)
  end

  def candidate_full_name
    audit.auditable.try(:application_form)&.full_name ||
      audit.associated.try(:application_form)&.full_name
  end

  def application_status_at_event
    return unless audit.auditable.respond_to?(:status)

    changes['status'].second if changes.key?('status')
  end
end

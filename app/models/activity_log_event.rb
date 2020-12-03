class ActivityLogEvent < Audited::Audit
  def user_full_name
    user.try(:full_name) || user.try(:display_name)
  end

  def candidate_full_name
    auditable.try(:application_form)&.full_name
  end

  def application_status_at_event
    return unless auditable.respond_to?(:status)

    audited_changes['status'].second if audited_changes.key?('status')
  end
end

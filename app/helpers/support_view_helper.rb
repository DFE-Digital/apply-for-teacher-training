module SupportViewHelper
  def audit_entry_label(audit)
    "#{audit_entry_event_label(audit)} - #{audit_entry_user_label(audit)}"
  end

private

  def audit_entry_event_label(audit)
    "#{audit.action.capitalize} #{audit.auditable_type.titlecase}"
  end

  def audit_entry_user_label(audit)
    if audit.user.is_a? Candidate
      "#{audit.user.email_address} (Candidate)"
    elsif audit.user.is_a? VendorApiUser
      "#{audit.user.email_address} (Vendor API)"
    else
      '(Unknown User)'
    end
  end
end

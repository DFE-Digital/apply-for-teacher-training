module SupportInterface
  class AuditTrailItemComponent < ActionView::Component::Base
    include ViewHelper

    validates :audit, presence: true

    def initialize(audit:)
      @audit = audit
    end

    def audit_entry_event_label
      "#{audit.action.capitalize} #{audit.auditable_type.titlecase}"
    end

    def audit_entry_user_label
      if audit.user_type == 'Candidate'
        "#{audit.user.email_address} (Candidate)"
      elsif audit.user_type == 'VendorApiUser'
        "#{audit.user.email_address} (Vendor API)"
      elsif audit.username.present?
        audit.username
      else
        '(Unknown User)'
      end
    end

    def changes
      audit.audited_changes.select { |_, values| audit_value_present?(values) }
    end

    def audit_value_present?(value)
      if value.is_a? Array
        value.any?(&:present?)
      else
        value.present?
      end
    end

    attr_reader :audit
  end
end
